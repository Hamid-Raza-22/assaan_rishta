import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/export.dart';
import '../../../utils/exports.dart';

class ClickableListTile extends StatelessWidget {
  final String? text;
  final Color? textColor;
  final IconData? icon;
  final String? iconPath;
  final VoidCallback? onTap;
  final ImageType? imageType;

  const ClickableListTile({
    super.key,
    required this.text,
    this.textColor,
    this.iconPath,
    this.imageType,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: icon == null
            ? SizedBox(
                height: 25,
                width: 25,
                child: ImageHelper(
                  image: iconPath ?? "",
                  imageType: imageType ?? ImageType.asset,
                  color: Colors.grey,
                ),
              )
            : Icon(
                icon,
                color: Colors.grey,
                size: 25,
              ),
        title: Text(
          text ?? '',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: textColor ?? AppColors.blackColor,
          ),
        ),
        trailing: const Icon(
          CupertinoIcons.right_chevron,
          color: Colors.grey,
        ),
      ),
    );
  }
}
