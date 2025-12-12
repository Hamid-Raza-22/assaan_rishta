import 'package:get/get.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Delete any existing instance first to avoid conflicts
    if (Get.isRegistered<LoginViewModel>()) {
      Get.delete<LoginViewModel>(force: true);
    }
    // Create a fresh controller instance for this route
    Get.put<LoginViewModel>(LoginViewModel());
  }
}
