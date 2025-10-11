import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  var currentPage = 0.obs;

  final onboardingData = [
    {
      "video": "assets/videos/AR_INTRO_1.mp4",
      "title": "Welcome to Asaan Rishta App!",
      "subtitle": "Before you start using the application, please take a moment to watch these short videos."
    },
    {
      "video": "assets/videos/How_to_use_video_AR.mp4",
      "title": "Welcome to Asaan Rishta App!",
      "subtitle": "They’ll guide you on how to use the app safely and effectively, so you can get the best experience."
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

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    Get.offAllNamed(AppRoutes.SPLASH);
  }
}
