import 'package:flutter/material.dart';

import '../utils/exports.dart';
import 'export.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color? backgroundColor, borderColor, fontColor;
  final double? radios, width, height;
  final double? fontSize;
  final EdgeInsetsGeometry? margin;
  final Widget? prefixIcon, suffixIcon;
  final bool isGradient;
  final bool isLoading;
  final bool isEnable;
  final FontWeight? fontWeight;
  final double? suffixWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.radios,
    this.width,
    this.height,
    this.fontSize,
    this.margin,
    this.prefixIcon,
    this.suffixIcon,
    this.fontColor,
    this.isGradient = false,
    this.isLoading = false,
    this.isEnable = true,
    this.fontWeight,
    this.suffixWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnable ? onTap : null,
      child: Container(
        width: width ?? MediaQuery.sizeOf(context).width,
        height: height ?? 52,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 04),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.blackColor,
          borderRadius: BorderRadius.circular(radios ?? 10),
          border: Border.all(color: borderColor ?? Colors.transparent),
          gradient: isGradient
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.secondaryColor,
                  ],
                )
              : null,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.whiteColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  prefixIcon ?? const SizedBox.shrink(),
                  AppText(
                    text: text,
                    color: fontColor,
                    fontWeight: fontWeight,
                    fontSize: fontSize ?? 20,
                  ),
                   SizedBox(width: suffixWidth),
                  suffixIcon ?? const SizedBox.shrink(),
                ],
              ),
      ),
    );
  }
}
