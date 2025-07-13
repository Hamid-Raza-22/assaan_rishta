
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
