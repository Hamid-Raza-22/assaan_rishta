import 'dart:async';

import 'package:assaan_rishta/app/core/routes/app_routes.dart';
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
           Get.offNamed(AppRoutes.BOTTOM_NAV);
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
