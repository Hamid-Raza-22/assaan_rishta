// lib/app/viewmodels/signup_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class SignupViewModel extends GetxController {
  final AuthRepository _authRepository;

  SignupViewModel(this._authRepository);

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(text: '+92 ');
  final dobController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var selectedGender = 'Male'.obs;
  var isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    [firstNameController, lastNameController, emailController, phoneController, dobController, passwordController]
        .forEach((controller) => controller.addListener(validateForm));
  }

  void validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.length > 4 &&
        dobController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void selectGender(String gender) => selectedGender.value = gender;

  Future<void> selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }
// Validation Methods

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    final user = UserModel(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      dateOfBirth: dobController.text.trim(),
      password: passwordController.text.trim(),
      gender: selectedGender.value,
    );

    final success = await _authRepository.signUp(user);
    if (success) {
      Get.snackbar('Success', 'Account created successfully!', backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Failed to create account.', backgroundColor: Colors.red, colorText: Colors.white);
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
