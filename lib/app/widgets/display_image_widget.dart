import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

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
    final image = imagePath.contains('https://')
        ? NetworkImage(imagePath)
        : FileImage(File(imagePath));

    Widget avatarWidget = CircleAvatar(
      backgroundImage: image as ImageProvider,
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
                image: image as ImageProvider,
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
