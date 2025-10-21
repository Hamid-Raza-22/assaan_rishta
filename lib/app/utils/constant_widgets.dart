import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

import 'exports.dart';

CustomDropdownDecoration? basicInfoDecoration({
  TextStyle? hintStyle,
  bool hasError = false,
}) =>
    CustomDropdownDecoration(
      closedFillColor: AppColors.fillFieldColor,
      expandedFillColor: AppColors.whiteColor,
      closedBorder: Border.all(
        color: hasError ? Colors.red : AppColors.borderColor,
        width: hasError ? 1.5 : 1.0,
      ),
      expandedBorder: Border.all(
        color: hasError ? Colors.red : AppColors.borderColor,
        width: hasError ? 1.5 : 1.0,
      ),
      hintStyle: hintStyle,
      closedSuffixIcon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.blackColor,
      ),
      expandedSuffixIcon: const Icon(
        Icons.keyboard_arrow_up,
        color: AppColors.blackColor,
      ),
      listItemDecoration: ListItemDecoration(
        selectedColor: AppColors.fontLightColor.withValues(alpha: 0.4),
        highlightColor: Colors.grey[800],
      ),
    );

CustomDropdownDecoration? multiSelectionDecoration({TextStyle? hintStyle}) =>
    CustomDropdownDecoration(
      closedFillColor: AppColors.fillFieldColor,
      expandedFillColor: AppColors.whiteColor,
      closedBorder: Border.all(color: AppColors.borderColor),
      expandedBorder: Border.all(color: AppColors.borderColor),
      hintStyle: hintStyle,
      closedSuffixIcon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.blackColor,
      ),
      expandedSuffixIcon: const Icon(
        Icons.keyboard_arrow_up,
        color: AppColors.blackColor,
      ),
      listItemDecoration: ListItemDecoration(
        selectedColor: AppColors.greyColor.withValues(alpha: 0.2),
        highlightColor: Colors.grey,
      ),
    );
