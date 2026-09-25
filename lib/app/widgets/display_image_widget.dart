import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_assets.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final bool shouldBlur;

  // Constructor
  const DisplayImage({
    super.key,
    required this.imagePath,
    required this.onPressed,
    this.shouldBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF1C4E80);
    return GestureDetector(
      onTap: onPressed,
      child: buildImage(
        radius: 45,
        color: color,
        imagePath: imagePath,
      ),
    );
  }

// Builds Profile Image
  Widget buildImage({
    required double radius,
    Color color = const Color(0xFF1C4E80),
    required String imagePath,
  }) {
    final trimmedPath = imagePath.trim();
    final effectivePath = trimmedPath.isEmpty ? AppAssets.imagePlaceholder : trimmedPath;

    final ImageProvider imageProvider = effectivePath.startsWith('http://') || effectivePath.startsWith('https://')
        ? NetworkImage(effectivePath)
        : (effectivePath.startsWith('assets/')
            ? AssetImage(effectivePath) as ImageProvider
            : FileImage(File(effectivePath)) as ImageProvider);

    Widget avatarWidget = CircleAvatar(
      backgroundImage: imageProvider,
      radius: radius - 2,
    );

    if (shouldBlur) {
      final diameter = (radius - 2) * 2;
      avatarWidget = ClipOval(
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: avatarWidget,
    );
  }
}
