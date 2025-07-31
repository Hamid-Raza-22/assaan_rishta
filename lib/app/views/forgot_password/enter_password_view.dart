import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/export.dart';
import '../../utils/exports.dart';
import '../../widgets/export.dart';
import 'export.dart';

class EnterPasswordView extends GetView<ForgotPasswordController> {
  const EnterPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      initState: (_) {
        Get.put(ForgotPasswordController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: const PreferredSize(
            preferredSize: Size(double.infinity, 40),
            child: CustomAppBar(
              isBack: true,
            ),
          ),
          body: SafeArea(
            child: Form(
              key: controller.enterPasswordFormKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 35),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText(
                          text: "Forgot Password",
                          color: AppColors.blackColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 05),
                        AppText(
                          text: "Please enter your password",
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
                        const SizedBox(height: 16),
                        CustomFormField(
                          tec: controller.newPasswordTEC,
                          hint: 'New Password',
                          obscureText: controller.showPassword.value,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.fontLightColor.withValues(alpha: 0.6),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              controller.showPassword.value =
                              !controller.showPassword.value;
                              controller.update();
                            },
                            child: Icon(
                              controller.showPassword.isTrue
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
                          obscureText: controller.showPassword.value,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.fontLightColor.withValues(alpha: 0.6),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              controller.showPassword.value =
                              !controller.showPassword.value;
                              controller.update();
                            },
                            child: Icon(
                              controller.showPassword.isTrue
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.remove_red_eye_rounded,
                              color: AppColors.fontLightColor.withValues(alpha: 0.6),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter confirm password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: "Update",
                          isGradient: true,
                          fontColor: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          onTap: () {
                            if (controller.enterPasswordFormKey.currentState!.validate()) {

                            }
                          },
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
