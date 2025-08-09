import 'package:assaan_rishta/app/viewmodels/signup_viewmodel.dart';
import 'package:get/get.dart';
import '../core/routes/app_routes.dart';

class AccountTypeViewModel extends GetxController {
  void navigateToSignup() {
    final signupController = Get.find<SignupViewModel>();
    signupController.clearFormData();
    Get.toNamed(AppRoutes.SIGNUP);
  }

  void navigateToLogin() {
    Get.toNamed(AppRoutes.LOGIN);
  }
  void continueAsGuest() {
    // Navigate back to home as guest user
    Get.offAllNamed(AppRoutes.BOTTOM_NAV);

    // Show a brief message
    Get.snackbar(
      'Guest Mode',
      'You are browsing as a guest. Login to access all features.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
