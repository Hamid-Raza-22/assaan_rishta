import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
                        AppText(
                          text: "Please Change Your Password",
                          color: AppColors.fontLightColor.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
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
                          flagsButtonMargin: const EdgeInsets.only(left: 10),
                          decoration: InputDecoration(
                            hintText: 'Mobile Number',
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
                          ),
                          cursorColor: AppColors.primaryColor,
                          initialCountryCode: 'PK',
                          disableLengthCheck: true,
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Invalid Mobile Number';
                            }
                            return null;
                          },
                          onCountryChanged: (countryCode) {
                            controller.countryCode.value = "+${countryCode.dialCode}";
                          },
                          onChanged: (value) {
                            controller.phoneTEC.text = value.number;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: "Next",
                          isGradient: true,
                          fontColor: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          onTap: () {
                            if (controller.formKey.currentState!.validate()) {
                              Get.toNamed(AppRoutes.ENTER_PASSWORD_VIEW);
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
