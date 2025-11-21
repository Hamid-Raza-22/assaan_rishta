import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../viewmodels/signup_viewmodel.dart';

class ProfilePhotoPicker extends StatelessWidget {
  final SignupViewModel controller;

  const ProfilePhotoPicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        GestureDetector(
          onTap: () => controller.showPhotoOptions(context),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: controller.profilePhoto.value != null
                  ? null
                  : LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.secondaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: Border.all(
                color: controller.profilePhoto.value != null
                    ? AppColors.primaryColor
                    : Colors.grey[300]!,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Profile photo or placeholder
                ClipOval(
                  child: controller.profilePhoto.value != null
                      ? Image.file(
                          controller.profilePhoto.value!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[50],
                          child: Icon(
                            Icons.person_outline,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
                // Edit/Add icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      controller.profilePhoto.value != null
                          ? Icons.edit
                          : Icons.add_a_photo,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          controller.profilePhoto.value != null
              ? 'Tap to change photo'
              : 'Add Profile Photo',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (controller.photoError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              controller.photoError.value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
        SizedBox(height: 8),
        Text(
          '(Optional)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ));
  }
}
