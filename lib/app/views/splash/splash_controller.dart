import 'dart:async';

import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:assaan_rishta/app/core/services/deep_link_handler.dart';
import 'package:get/get.dart';

import '../../core/base/export.dart';
import '../../domain/export.dart';

class SplashController extends BaseController {
  UserManagementUseCase useCase;

  SplashController(this.useCase);

  @override
  void onInit() async {
    super.onInit();
    _handleNavigation();
  }

  void _handleNavigation() async {
    // Wait for splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));

    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();

    if (isLoggedIn) {
      // Navigate to bottom nav first
      Get.offNamed(AppRoutes.BOTTOM_NAV);

      // Process any pending deep links after navigation
      // This ensures proper navigation stack
      Future.delayed(const Duration(milliseconds: 500), () {
        DeepLinkHandler.processPendingDeepLink();
      });
    } else {
      // For non-logged in users, check if there's a pending deep link
      // If yes, it will handle navigation, otherwise go to account type

      // Try to process pending deep link first
      DeepLinkHandler.processPendingDeepLink();

      // If no deep link was processed (still on splash), go to account type
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.currentRoute == AppRoutes.SPLASH || Get.currentRoute == '/') {
          Get.offNamed(AppRoutes.ACCOUNT_TYPE);
        }
      });
    }
  }
}