import 'package:get/get.dart';
import '../../viewmodels/user_details_viewmodel.dart';

class UserDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // Create a fresh controller instance for each navigation
    Get.lazyPut<UserDetailsController>(
      () => UserDetailsController(),
      fenix: true,
    );
  }
}
