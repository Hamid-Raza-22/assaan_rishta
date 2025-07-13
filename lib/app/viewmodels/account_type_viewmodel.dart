import 'package:get/get.dart';
import '../core/routes/app_routes.dart';

class AccountTypeViewModel extends GetxController {
  void navigateToSignup() {
    Get.toNamed(AppRoutes.SIGNUP);
  }

  void navigateToLogin() {
    Get.toNamed(AppRoutes.LOGIN);
  }
}
