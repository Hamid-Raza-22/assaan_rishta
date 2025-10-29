import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'custom_onboarding.dart';


class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          physics: const NeverScrollableScrollPhysics(), // 🛑 Disable manual swipe
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          itemCount: controller.onboardingData.length,
          itemBuilder: (context, index) {
            final data = controller.onboardingData[index];
            return CustomOnboardingPage(
              video: data["video"]!,
              title: data["title"]!,
              // subtitle: data["subtitle"],
              index: index,
            );
          },
        ),
      ),
    );
  }
}
