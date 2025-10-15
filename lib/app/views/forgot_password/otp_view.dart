import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/exports.dart';
import '../../widgets/export.dart';
import 'export.dart';

class OtpView extends GetView<ForgotPasswordController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      initState: (_) {
        if (!Get.isRegistered<ForgotPasswordController>()) {
          Get.put(ForgotPasswordController());
        }
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
              key: controller.otpFormKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 35),
                    const AppText(
                      text: "Verify Phone",
                      color: AppColors.blackColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: "Enter the 6-digit code sent to your number",
                      color: AppColors.fontLightColor.withValues(alpha: 0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(height: 24),
                    // OTP Field with Paste Button
                    TextFormField(
                      controller: controller.otpTEC,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter OTP',
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.fillFieldColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: Obx(() => controller.isPasting.value
                            ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                            : InkWell(
                          onTap: () => controller.pasteAndVerifyOtp(context: context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            child: const Text(
                              'Paste',
                              style: TextStyle(
                                color: AppColors.secondaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.borderColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.secondaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length != 6) {
                          return 'Enter 6-digit code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Obx(() => CustomButton(
                      text: controller.isVerifyingOtp.value
                          ? 'Verifying...'
                          : 'Verify',
                      isGradient: true,
                      fontColor: AppColors.whiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      onTap: controller.isVerifyingOtp.value
                          ? null
                          : () {
                        if (controller.otpFormKey.currentState!
                            .validate()) {
                          controller.verifyOtpAndProceed(
                              context: context);
                        }
                      },
                    )),
                    const SizedBox(height: 12),
                    Obx(() => TextButton(
                      onPressed: controller.isSendingCode.value
                          ? null
                          : () {
                        controller.resendCode();
                      },
                      child: Text(
                        controller.isSendingCode.value
                            ? 'Resending...'
                            : 'Resend Code',
                        style: const TextStyle(
                            color: AppColors.secondaryColor),
                      ),
                    )),
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
