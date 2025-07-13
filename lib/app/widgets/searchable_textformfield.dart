import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/exports.dart';

class SearchableTextFormField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final bool? showClearFieldIcon;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final Function(PointerDownEvent)? onTapOutside;

  const SearchableTextFormField({
    super.key,
    this.hintText,
    required this.labelText,
    required this.controller,
    this.onChanged,
    this.showClearFieldIcon,
    this.contentPadding,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.onTap,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.search,
      controller: controller,
      textCapitalization: TextCapitalization.words,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: AppColors.primaryColor,
      onTapOutside: (event){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onTap: onTap,
      decoration: InputDecoration(
        contentPadding: contentPadding,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: hintText ?? '',
        labelText: labelText,
        labelStyle: GoogleFonts.sora(
          color: AppColors.borderColor,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: AppColors.borderColor,
            width: 2.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 2.0,
          ),
        ),
        prefixIcon: const Icon(
          CupertinoIcons.search,
          color: AppColors.borderColor,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  unFocusKeyboard(context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  focusKeyboard(context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
