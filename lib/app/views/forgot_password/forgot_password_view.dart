// forgot_password_view.dart - UPDATED WITH PHONE VALIDATION
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../core/routes/app_routes.dart';
import '../../utils/exports.dart';
import '../../widgets/export.dart';
import 'export.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

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
              key: controller.formKey,
              child: Padding(
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
                        Obx(() {
                          return Column(
                            children: [
                              AppText(
                                text: "Enter your registered mobile number to receive OTP",
                                color: AppColors.fontLightColor.withValues(alpha: 0.4),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                textAlign: TextAlign.center,
                              ),
                              if (controller.maskedNumber.value.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                AppText(
                                  text: "Registered Number: ${controller.maskedNumber.value}",
                                  color: AppColors.primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 40),
                        IntlPhoneField(
                          controller: controller.phoneTEC,
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          dropdownTextStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          dropdownIconPosition: IconPosition.trailing,
                          dropdownIcon: const Icon(
                            CupertinoIcons.chevron_down,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                            signed: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _NoSpaceInputFormatter(),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          flagsButtonMargin: const EdgeInsets.only(left: 10),
                          decoration: InputDecoration(
                            hintText: 'Enter Number',
                            filled: true,
                            fillColor: AppColors.fillFieldColor,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.borderColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.secondaryColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          cursorColor: AppColors.primaryColor,
                          initialCountryCode: 'PK',
                          disableLengthCheck: true,
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            // Additional validation will happen in controller
                            return null;
                          },
                          onCountryChanged: (countryCode) {
                            controller.countryCode.value = "+${countryCode.dialCode}";
                          },
                        ),
                        const SizedBox(height: 8),
                        // Help text
                        Obx(() {
                          if (controller.savedPhoneNumber.value.isEmpty) {
                            return const AppText(
                              text: "No registered number found. Please contact support.",
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              textAlign: TextAlign.center,
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        const SizedBox(height: 16),
                        Obx(() => CustomButton(
                          text: controller.isSendingCode.value
                              ? "Sending..."
                              : "Send OTP",
                          isGradient: true,
                          fontColor: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          onTap:
                               // ()=> Get.toNamed(AppRoutes.ENTER_PASSWORD_VIEW)
                          controller.isSendingCode.value
                              ? null
                              : () {
                            if (controller.formKey.currentState!.validate()) {
                              // Check if saved number exists
                              if (controller.savedPhoneNumber.value.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'No registered phone number found. Please contact support.',
                                  backgroundColor: Colors.red.withOpacity(0.9),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.TOP,
                                );
                                return;
                              }
                              controller.startPhoneVerification(context: context);
                            }
                          },
                        )),
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

/// Custom input formatter that removes spaces from input
/// Also handles pasted text with spaces by cleaning them
class _NoSpaceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all spaces from the input (handles both typing and pasting)
    final newText = newValue.text.replaceAll(' ', '');
    
    if (newText == newValue.text) {
      return newValue;
    }
    
    // Adjust cursor position after removing spaces
    final cursorOffset = newValue.selection.baseOffset - 
        (newValue.text.length - newText.length);
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, newText.length),
      ),
    );
  }
}