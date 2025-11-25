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
  final bool isCircular;

  const BlurredProfileImage({
    super.key,
    required this.imageProvider,
    this.shouldBlur = false,
    this.width,
    this.height,
    this.boxFit = BoxFit.cover,
    this.borderRadius,
    this.blurSigma = 10.0,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    // For circular images, wrap everything once
    if (isCircular) {
      // Debug print
      if (shouldBlur) {
        debugPrint('🔵 Applying blur - Circular: $isCircular, Sigma: $blurSigma, Size: ${width}x${height}');
      }
      
      return ClipOval(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: imageProvider,
                fit: boxFit,
              ),
              if (shouldBlur)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurSigma,
                      sigmaY: blurSigma,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // For rectangular/border radius images
    Widget imageWidget = SizedBox(
      width: width,
      height: height,
      child: Image(
        image: imageProvider,
        fit: boxFit,
      ),
    );

    if (shouldBlur) {
      imageWidget = SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Handle border radius
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
