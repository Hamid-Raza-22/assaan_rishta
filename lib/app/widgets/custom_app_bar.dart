
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../utils/exports.dart';
import 'app_text.dart';

class CustomAppBar extends StatelessWidget {
  final bool isBack;
  final String? title;
  final List<Widget>? actions;
  final Color? color;
  final Color? textColor;

  const CustomAppBar({
    super.key,
    this.isBack = false,
    this.title,
    this.actions,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color ?? AppColors.whiteColor,
      surfaceTintColor: color ?? AppColors.whiteColor,
      leading: isBack
          ? IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: textColor,
              ),
            )
          : const SizedBox.shrink(),
      centerTitle: true,
      title: title != null
          ? AppText(
              text: title,
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.w500,
            )
          : const SizedBox.shrink(),
      actions: actions,
    );
  }
}

class CustomAppBar2 extends StatelessWidget {
  final bool isBack;
  final String? title;
  final List<Widget>? actions;
  final Color? color;
  final Color? textColor;

  const CustomAppBar2({
    super.key,
    this.isBack = false,
    this.title,
    this.actions,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color ?? AppColors.whiteColor,
      surfaceTintColor: color ?? AppColors.whiteColor,
      leading: isBack
          ? IconButton(
              onPressed: () async {
                 await navigateBack();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: textColor,
              ),
            )
          : const SizedBox.shrink(),
      centerTitle: true,
      title: title != null
          ? AppText(
              text: title,
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.w500,
            )
          : const SizedBox.shrink(),
      actions: actions,
    );
  }
  navigateBack() async {
    debugPrint('⬅️ Navigating back from chat');

    // Small delay for smooth transition
    // Future.delayed(const Duration(milliseconds: 100), () {
    if (Navigator.of(Get.context!).canPop()) {
      // Get.offNamed(AppRoutes.BOTTOM_NAV2, arguments: 2);
      Get.back();
    } else {
      Get.offNamed(AppRoutes.BOTTOM_NAV2);
      //Get.to(() => const BottomNavView(index: 2));
    }
    // });
  }
}
