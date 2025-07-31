import 'dart:async';

import 'package:get/get.dart';

import '../../core/base/export.dart';
import '../../domain/export.dart';





class SplashController extends BaseController {
  UserManagementUseCase useCase;

  SplashController(this.useCase);

  @override
  void onInit() async {
    super.onInit();
    bool status = useCase.userManagementRepo.getUserLoggedInStatus();
    if (status) {
      Timer(
        const Duration(seconds: 3),
        () {
          // Get.offAll(
          //   () => const BottomNavView(),
          //   binding: AppBindings(),
          //   transition: Transition.circularReveal,
          //   duration: const Duration(milliseconds: 500),
          // );
        },
      );
    }
  }
}
