import 'package:assaan_rishta/app/viewmodels/signup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/routes/app_routes.dart';
import '../core/services/secure_storage_service.dart';

/// Enum for account types
enum AccountType { rishtaUser, matrimonial }

class AccountTypeViewModel extends GetxController {
  /// Selected account type - defaults to Rishta User
  final Rx<AccountType> selectedAccountType = AccountType.rishtaUser.obs;

  /// Animation controller for smooth transitions
  final RxBool isTransitioning = false.obs;

  /// Select account type with smooth transition
  void selectAccountType(AccountType type) {
    if (selectedAccountType.value == type) return;
    
    isTransitioning.value = true;
    selectedAccountType.value = type;
    
    // Small delay for smooth animation
    Future.delayed(const Duration(milliseconds: 150), () {
      isTransitioning.value = false;
      update();
    });
    
    update();
  }

  /// Check if Rishta User is selected
  bool get isRishtaUserSelected => selectedAccountType.value == AccountType.rishtaUser;

  /// Check if Matrimonial is selected
  bool get isMatrimonialSelected => selectedAccountType.value == AccountType.matrimonial;

  void navigateToSignup() {
    final signupController = Get.find<SignupViewModel>();
    signupController.clearFormData();
    Get.toNamed(AppRoutes.SIGNUP);
  }

  void navigateToLogin() {
    // Save the selected account type before navigating
    _saveSelectedAccountType();
    Get.toNamed(AppRoutes.LOGIN);
  }

  /// Save selected account type for login validation
  Future<void> _saveSelectedAccountType() async {
    final secureStorage = SecureStorageService();
    final isMatrimonial = selectedAccountType.value == AccountType.matrimonial;
    await secureStorage.write('login_as_matrimonial', isMatrimonial.toString());
  }

  /// Get if user is trying to login as matrimonial
  static Future<bool> isLoginAsMatrimonial() async {
    final secureStorage = SecureStorageService();
    final value = await secureStorage.read('login_as_matrimonial');
    return value == 'true';
  }

  void navigateToContactUs() {
    Get.toNamed(AppRoutes.CONTACT_US_VIEW);
  }

  void navigateToUserGuide() {
    Get.toNamed(AppRoutes.USER_GUIDE_VIEW);
  }

  void continueAsGuest() {
    // Navigate back to home as guest user
    Get.offAllNamed(AppRoutes.BOTTOM_NAV);

    // Show a brief message
    Get.snackbar(
      'Guest Mode',
      'You are browsing as a guest. Login to access all features.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
