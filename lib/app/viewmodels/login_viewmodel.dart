import 'package:assaan_rishta/app/viewmodels/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/routes/app_routes.dart';

import '../core/services/storage_services/export.dart';

import '../domain/export.dart';
import '../utils/exports.dart';
import 'auth_service.dart';

class LoginViewModel extends GetxController {
  final userManagementUseCase = Get.find<UserManagementUseCase>();
  final chatController = Get.find<ChatViewModel>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var rememberMe = false.obs;
  // var agreeToTerms = false.obs;
  var isFormValid = false.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    isFormValid.value =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  }

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleRememberMe() => rememberMe.value = !rememberMe.value;

  //void toggleAgreeToTerms() => agreeToTerms.value = !agreeToTerms.value;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Please enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 4) return 'Password must be at least 4 characters';
    return null;
  }

 login(context) async {
    if (!formKey.currentState!.validate()) return;

    // if (!agreeToTerms.value) {
    //   Get.snackbar('Terms & Conditions', 'Please agree to Terms & Conditions',
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Colors.red,
    //       colorText: Colors.white);
    //   return;
    // }

    isLoading.value = true;
    Map<String, dynamic> body = {
      'username': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'grant_type': "password"
    };
    try {
      // final loginData = LoginModel(
      //   email: emailController.text.trim(),
      //   password: passwordController.text.trim(),
      //   rememberMe: rememberMe.value,
      // );
      final response = await userManagementUseCase.login(body: body);
      return response.fold(
            (error) {
          isLoading.value = false;
          if (error.title == "400") {
            if (error.description == 'invalid_grant') {
              AppUtils.failedData(
                title: "Invalid Credentials",
                message: "Your Email or Password is Incorrect",
              );
            } else {
              AppUtils.failedData(
                title: "Account Status",
                message: "Your Account is not Approved Yet",
              );
            }
          } else {
            AppUtils.failedData(
              title: "Server Error",
              message: "There is some error in server please try a later",
            );
          }
          update();
        },
            (success) {
          getCurrentUserProfiles(context);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }
  // login_viewmodel.dart me getCurrentUserProfiles method fix karo
  // login_viewmodel.dart me getCurrentUserProfiles को safe banao
  getCurrentUserProfiles(context) async {
    final response = await userManagementUseCase.getDonorClaims();
    return response.fold(
          (error) {
        isLoading.value = false;
        AppUtils.failedData(
          title: "Error",
          message: "Failed to get user profile",
        );
        update();
      },
          (success) async {
        try {
          isLoading.value = false;
          final pref = await SharedPreferences.getInstance();

          // SAFE USER ID HANDLING
          final safeUserId = success.userId ?? 0;
          final safeName = "${success.firstName ?? ''} ${success.lastName ?? ''}";
          final safeEmail = success.email ?? '';

          debugPrint('👤 User data: ID=$safeUserId, Name=$safeName, Email=$safeEmail');

          // SAVE USER DATA SAFELY
          await pref.setString(StorageKeys.userPassword, passwordController.text);
          await pref.setInt(StorageKeys.userId, safeUserId);
          await pref.setString(StorageKeys.userEmail, safeEmail);
          await pref.setString(StorageKeys.userName, safeName);
          await pref.setString(StorageKeys.userPic, AppConstants.profileImg);
          await pref.setBool(StorageKeys.isUserLoggedIn, true);

          debugPrint('💾 User data saved to preferences');

          // Use AuthService for login
          final authService = AuthService.instance;
          await authService.login(
            userId: safeUserId,
            email: safeEmail,
            name: safeName,
            image: AppConstants.profileImg,
          );

          // Create chat user with safe data
          if (safeUserId > 0 && safeName.isNotEmpty && safeEmail.isNotEmpty) {
            await chatController.createUser(
              name: safeName,
              id: safeUserId.toString(),
              email: safeEmail,
              image: AppConstants.profileImg,
              isOnline: true,
              isMobileOnline: true,
            );
            debugPrint('💬 Chat user created successfully');
          }

          AppUtils.successData(
            title: "Login",
            message: "Login successfully",
          );

          update();
          Get.offAllNamed(AppRoutes.BOTTOM_NAV);

        } catch (e) {
          debugPrint('💥 Error in getCurrentUserProfiles: $e');
          isLoading.value = false;
          AppUtils.failedData(
            title: "Error",
            message: "Failed to process user data",
          );
        }
      },
    );
  }
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
