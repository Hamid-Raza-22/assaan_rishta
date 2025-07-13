import 'dart:io';

import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  // Constructor
  const DisplayImage({
    super.key,
    required this.imagePath,
    required this.onPressed,
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

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: CircleAvatar(
        backgroundImage: image as ImageProvider,
        radius: radius - 2,
      ),
    );
  }
}
