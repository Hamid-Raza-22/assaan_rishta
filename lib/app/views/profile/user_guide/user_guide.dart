import 'package:assaan_rishta/app/views/profile/user_guide/tutorial_card.dart';
import 'package:assaan_rishta/app/views/profile/user_guide/user_guide_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/sub_tabs.dart';
import '../../../widgets/tab_bar.dart';

import 'FAQs.dart';

class UserGuideScreen extends GetView<UserGuideController> {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 40),
        child: CustomAppBar(
          isBack: true,
          title: "User Guide",
          color: AppColors.whiteColor,
          textColor: AppColors.blackColor,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====== Main Tabs (FAQs, Tutorials) ======
          Obx(() => CustomTabBar(
            tabs: controller.mainTabs,
            selectedIndex: controller.selectedMainTab.value,
            onTap: controller.changeMainTab,
          )),

          // ====== Sub Tabs ======
          Obx(() => controller.selectedMainTab.value == 0
              ? SubTabBar(
            tabs: controller.subTabs,
            selectedIndex: controller.selectedSubTab.value,
            onTap: controller.changeSubTab,
          )
              : const SizedBox.shrink()),

          const SizedBox(height: 10),

          // ====== Content Area ======
          Expanded(
            child: Obx(() {
              // Show FAQs
              if (controller.selectedMainTab.value == 0) {
                final faqs = controller.currentFaqs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: faqs.length,
                  itemBuilder: (ctx, i) => FAQItem(
                    question: faqs[i]['q']!,
                    answer: faqs[i]['a']!,
                  ),
                );
              }
              // Show Tutorials
              else {
                final tutorials = controller.tutorials;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: tutorials.length,
                  itemBuilder: (ctx, i) => TutorialCard(
                    title: tutorials[i]['title']!,
                    description: tutorials[i]['description']!,
                    thumbnail: tutorials[i]['thumbnail']!,
                    url: tutorials[i]['url']!,
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}