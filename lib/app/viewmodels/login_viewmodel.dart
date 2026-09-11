import 'package:assaan_rishta/app/viewmodels/chat_viewmodel.dart';
import 'package:assaan_rishta/app/viewmodels/bottom_nav_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../core/routes/app_routes.dart';
import '../core/services/env_config_service.dart';
import '../core/services/secure_storage_service.dart';


import '../domain/export.dart';
import '../utils/exports.dart';
import 'auth_service.dart';

class LoginViewModel extends GetxController {
  final userManagementUseCase = Get.find<UserManagementUseCase>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final chatController = Get.find<ChatViewModel>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  final RxBool forgotPassword = false.obs;

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
              isLoading.value = false;

            } else  if (error.description == 'account_not_approved') {
              AppUtils.failedData(
                title: "Account Status",
                message: "Your account is not approved please try again within 24 hours or call 03074052552",
              );
              isLoading.value = false;

            }
          } else {
            AppUtils.failedData(
              title: "Server Error",
              message: "There is some error in server please try a later",
            );
            isLoading.value = false;

          }
          update();
        },
            (success) async {
          await getCurrentUserProfiles(context);
        },
      );
    } finally {
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
          // SAFE USER ID HANDLING
          final safeUserId = success.userId ?? 0;
          final safeName = "${success.firstName ?? ''} ${success.lastName ?? ''}";
          final safeEmail = success.email ?? '';
          final roleId = success.roleId ?? 0;

          debugPrint('👤 User data: ID=$safeUserId, Name=$safeName, Email=$safeEmail, RoleId=$roleId');

          // ========== CRITICAL: STRICT ROLE-BASED LOGIN VALIDATION ==========
          final secureStorage = SecureStorageService();
          final loginAsMatrimonialValue = await secureStorage.read('login_as_matrimonial');
          final isMatrimonialLogin = loginAsMatrimonialValue == 'true';
          final isMatrimonialAccount = roleId == 3;

          debugPrint('🔐 Login as Matrimonial: $isMatrimonialLogin, RoleId: $roleId, isMatrimonialAccount: $isMatrimonialAccount');

          // BLOCK: Rishta user trying to login as Matrimonial
          if (isMatrimonialLogin && !isMatrimonialAccount) {
            isLoading.value = false;
            Get.snackbar(
              'Login Blocked',
              'This account is registered as a Rishta User. Please log in using the Rishta User option.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              margin: const EdgeInsets.all(10),
            );
            debugPrint('❌ LOGIN BLOCKED: Rishta account cannot login as Matrimonial');
            return;
          }

          // BLOCK: Matrimonial user trying to login as Rishta User
          if (!isMatrimonialLogin && isMatrimonialAccount) {
            isLoading.value = false;
            Get.snackbar(
              'Login Blocked',
              'This account is registered as a Matrimonial account. Please log in using the Matrimonial option.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              margin: const EdgeInsets.all(10),
            );
            debugPrint('❌ LOGIN BLOCKED: Matrimonial account cannot login as Rishta User');
            return;
          }

          debugPrint('✅ Role validation passed - proceeding with login');
          // ========== END ROLE VALIDATION ==========

          // SAVE USER DATA SECURELY
          await secureStorage.saveUserPassword(passwordController.text);
          await secureStorage.saveUserSession(
            userId: safeUserId,
            email: safeEmail,
            name: safeName,
            pic: AppConstants.profileImg,
          );
          await secureStorage.saveUserRoleId(roleId);

          debugPrint('💾 User data saved securely');

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

          // Refresh BottomNavController to reset tab index after login
          if (Get.isRegistered<BottomNavController>()) {
            final bottomNavController = Get.find<BottomNavController>();
            bottomNavController.refreshAfterLogin();
          }

          // Matrimonial users should NEVER see partner preference screen
          if (isMatrimonialAccount) {
            debugPrint('🏠 Matrimonial user - navigating directly to dashboard');
            Get.offAllNamed(AppRoutes.BOTTOM_NAV);
          } else {
            // Rishta users - check partner preference flag
            try {
              final doc = await FirebaseFirestore.instance
                  .collection(EnvConfig.firebaseUsersCollection)
                  .doc(safeUserId.toString())
                  .get();

              final data = doc.data();
              final bool isPreferenceUpdated =
                  data != null && (data['is_preference_updated'] == true);

              if (isPreferenceUpdated) {
                Get.offAllNamed(AppRoutes.BOTTOM_NAV);
              } else {
                Get.offAllNamed(AppRoutes.PARTNER_PREFERENCE_VIEW);
              }
            } catch (e) {
              Get.offAllNamed(AppRoutes.BOTTOM_NAV);
            }
          }
          isLoading.value = false;
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
