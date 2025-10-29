import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/secure_storage_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  var currentPage = 0.obs;

  final onboardingData = [
    {
      "video": "assets/videos/AR_INTRO_1.mp4",
      "title": "Welcome to Asaan Rishta App!",
      // "subtitle": "Before you start using the application, please take a moment to watch these short videos."
    },
    {
      "video": "assets/videos/How_to_use_video_AR.mp4",
      "title": "Welcome to Asaan Rishta App!",
      // "subtitle": "They’ll guide you on how to use the app safely and effectively, so you can get the best experience."
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  /// ✅ Called when video ends
  void goToNextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ Last video — mark onboarding complete and go to Splash
      _completeOnboarding();
    }
  }

  /// ✅ Called when skip button is pressed
  void onSkipPressed() {
    if (currentPage.value < onboardingData.length - 1) {
      // If not on last page, go to next page
      pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      // If on last page, complete onboarding and go to splash
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final secureStorage = SecureStorageService();
    await secureStorage.setHasSeenOnboarding(true);
    Get.offAllNamed(AppRoutes.SPLASH);
  }
}
