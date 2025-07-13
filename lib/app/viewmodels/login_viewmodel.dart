import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/login_model.dart';
import '../data/repositories/auth_repository.dart';

class LoginViewModel extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var rememberMe = false.obs;
  var agreeToTerms = false.obs;
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

  void toggleAgreeToTerms() => agreeToTerms.value = !agreeToTerms.value;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Please enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    if (!agreeToTerms.value) {
      Get.snackbar('Terms & Conditions', 'Please agree to Terms & Conditions',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final loginData = LoginModel(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        rememberMe: rememberMe.value,
      );

      final success = await _authRepository.login(loginData);
      if (success) {
        Get.snackbar('Success', 'Login successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        // Navigate to Home
      } else {
        Get.snackbar('Error', 'Invalid email or password',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
