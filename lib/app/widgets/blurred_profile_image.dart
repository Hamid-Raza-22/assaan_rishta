import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredProfileImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final bool shouldBlur;
  final double? width;
  final double? height;
  final BoxFit boxFit;
  final BorderRadius? borderRadius;
  final double blurSigma;

  const BlurredProfileImage({
    super.key,
    required this.imageProvider,
    this.shouldBlur = false,
    this.width,
    this.height,
    this.boxFit = BoxFit.cover,
    this.borderRadius,
    this.blurSigma = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: boxFit,
    );

    if (shouldBlur) {
      imageWidget = Stack(
        fit: StackFit.passthrough,
        children: [
          imageWidget,
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
