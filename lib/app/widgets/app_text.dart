import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;

  const AppText({
    super.key,
    this.text,
    this.fontWeight,
    this.fontSize,
    this.color,
    this.overflow,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$text',
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
