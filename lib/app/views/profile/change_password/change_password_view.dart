import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/export.dart';
import '../../../core/routes/app_routes.dart';
import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import 'export.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      initState: (_) {
        Get.put(ChangePasswordController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: const PreferredSize(
            preferredSize: Size(double.infinity, 40),
            child: CustomAppBar(
              title: "Change Password",
              isBack: true,
            ),
          ),
          body: SafeArea(
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText(
                          text: "Change Password",
                          color: AppColors.blackColor,
                          fontSize:28,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 05),
                        AppText(
                          text: "Please enter your new password",
                          color: AppColors.fontLightColor.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(height: 10),
                        ImageHelper(
                          image: AppAssets.changePassword,
                          imageType: ImageType.asset,
                          boxFit: BoxFit.contain,
                          height: 250,
                        ),
                        const SizedBox(height: 30),
                        CustomFormField(
                          tec: controller.passwordTEC,
                          hint: 'Old Password',
                          obscureText: controller.showOldPassword.value,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.fontLightColor.withValues(alpha: 0.6),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              controller.showOldPassword.value =
                                  !controller.showOldPassword.value;
                              controller.update();
                            },
                            child: Icon(
                              controller.showOldPassword.isTrue
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.remove_red_eye_rounded,
                              color: AppColors.fontLightColor.withValues(alpha: 0.6),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter password";
                            } else if (controller.oldPassword.value != value) {
                              return "Old password is not matched";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          tec: controller.newPasswordTEC,
                          hint: 'New Password',
                          obscureText: controller.showNewPassword.value,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.fontLightColor.withValues(alpha: 0.6),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              controller.showNewPassword.value =
                                  !controller.showNewPassword.value;
                              controller.update();
                            },
                            child: Icon(
                              controller.showNewPassword.isTrue
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.remove_red_eye_rounded,
                              color: AppColors.fontLightColor.withValues(alpha: 0.6),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter new password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          tec: controller.confirmPasswordTEC,
                          hint: 'Confirm Password',
                          obscureText: controller.showConfPassword.value,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.fontLightColor.withValues(alpha: 0.6),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              controller.showConfPassword.value =
                                  !controller.showConfPassword.value;
                              controller.update();
                            },
                            child: Icon(
                              controller.showConfPassword.isTrue
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.remove_red_eye_rounded,
                              color: AppColors.fontLightColor.withValues(alpha: 0.6),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter confirm password";
                            } else if (controller.newPasswordTEC.text !=
                                value) {
                              return "Confirm password is not matched";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Forgot Password Text Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Obx(() => GestureDetector(
                            onTap: controller.forgotPasswordLoading.value ? null : () async {
                              // Get email from secure storage
                              final email = await controller.secureStorage.getUserEmail();
                              
                              if (email == null || email.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Unable to retrieve email. Please login again.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  colorText: Colors.white,
                                  backgroundColor: Colors.red,
                                );
                                return;
                              }
                              
                              controller.forgotPasswordLoading.value = true;
                              try {
                                final response = await controller.systemConfigUseCases
                                    .getUserNumber(email);
                                if (response.isRight()) {
                                  final result = response.getOrElse(() => '');
                                  debugPrint('Response Body: $result');
                                  // Save phone number to secure storage
                                  await controller.secureStorage.saveUserPhone(result);
                                  await controller.secureStorage.saveUserEmail(email);
                                  debugPrint('✅ Phone and email saved securely');
                                  Get.toNamed(AppRoutes.FORGOT_PASSWORD_VIEW,
                                      arguments: {'email': email, 'source': 'profile'});
                                } else {
                                  Get.snackbar(
                                    'Not Found',
                                    "Email is not Registered",
                                    snackPosition: SnackPosition.BOTTOM,
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red,
                                  );
                                }
                              } finally {
                                controller.forgotPasswordLoading.value = false;
                              }
                            },
                            child: controller.forgotPasswordLoading.value
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            )
                                : const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          )),
                        ),
                        const SizedBox(height: 16),
                        Obx(()=>
                          CustomButton(
                            text: "Update",
                            isGradient: true,
                            isLoading: controller.isLoading.value,
                            fontColor: AppColors.whiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            onTap: () {
                              if (controller.formKey.currentState!.validate()) {
                                controller.updatePassword(context: context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
