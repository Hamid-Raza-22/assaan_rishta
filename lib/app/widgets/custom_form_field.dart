import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/exports.dart';

class CustomFormField extends StatelessWidget {
  final String? hint;
  final double? height;
  final Color? fillColor;
  final double fontSize;
  final double contentPadding;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextEditingController? tec;
  final bool? obscureText;
  final bool? readOnly;
  final void Function()? onFieldOnTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final int? lines;
  final Color? borderColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final FocusNode? focusNode;

  const CustomFormField({
    super.key,
    this.hint = "",
    this.fontSize = 14,
    this.contentPadding = 14,
    this.maxLength,
    this.onFieldOnTap,
    this.obscureText,
    this.height,
    this.keyboardType,
    this.tec,
    this.readOnly,
    this.inputFormatters,
    this.textInputAction,
    this.validator,
    this.fillColor,
    this.lines,
    this.borderColor,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 8,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: tec,
      showCursor: readOnly == true ? false : true,
      inputFormatters: inputFormatters,
      autocorrect: false,
      maxLength: maxLength,
      obscureText: obscureText ?? false,
      maxLines: lines ?? 1,
      readOnly: readOnly ?? false,
      cursorColor: AppColors.primaryColor,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      focusNode: focusNode,
      style: GoogleFonts.poppins(
        color: AppColors.blackColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.fillFieldColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: contentPadding,
          vertical: contentPadding,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? AppColors.borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? AppColors.borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.secondaryColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.fontLightColor.withValues(alpha: 0.6),
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      validator: validator,
      onTap: onFieldOnTap,
      onTapOutside: (event) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
    );
  }
}
