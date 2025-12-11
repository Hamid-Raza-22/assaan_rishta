import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../viewmodels/signup_viewmodel.dart';
import '../../../widgets/app_text.dart';

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
                color: controller.photoError.value.isNotEmpty
                    ? Colors.red
                    : controller.profilePhoto.value != null
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
                      ? SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                controller.profilePhoto.value!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                              // Apply blur effect when isProfileBlur is true
                              if (controller.isProfileBlur.value)
                                ClipRect(
                                  child: BackdropFilter(
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
                                ),
                            ],
                          ),
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
        AppText(
         text:  controller.profilePhoto.value != null
              ? 'Tap to change photo'
              : 'Add Profile Photo',
        ),
        if (controller.profilePhoto.value == null && controller.photoError.value.isEmpty)
          // Text(
          //   '(Required)',
          //   style: TextStyle(
          //     fontSize: 11,
          //     color: Colors.grey[500],
          //   ),
          // ),
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
        // Text(
        //   '(Optional)',
        //   style: TextStyle(
        //     fontSize: 12,
        //     color: Colors.grey[500],
        //     fontStyle: FontStyle.italic,
        //   ),
        // ),
      ],
    ));
  }
}
