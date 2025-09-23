import 'package:assaan_rishta/app/views/signup/widgets/custom_button.dart';
import 'package:assaan_rishta/app/views/signup/widgets/custom_text_field.dart';
import 'package:assaan_rishta/app/views/signup/widgets/gender_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../widgets/custom_checkbox.dart';
import 'basic_info_view.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/cupertino.dart';
class SignupView extends StatelessWidget {
  final SignupViewModel controller = Get.find<SignupViewModel>();

SignupView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Sign up to keep exploring profiles\naround the world',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: controller.firstNameController,
                      hintText: 'First Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) =>
                          controller.validateRequired(value, 'First Name'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: controller.lastNameController,
                      hintText: 'Last Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) =>
                          controller.validateRequired(value, 'Last Name'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              CustomTextField(
                controller: controller.emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              SizedBox(height: 10),
              IntlPhoneField(

                controller: controller.phoneController,
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
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                cursorColor: AppColors.primaryColor,
                initialCountryCode: 'PK',
                disableLengthCheck: true,
                validator: controller.validatePhone,
                onCountryChanged: (countryCode) {
                  controller.countryCode.value =
                  "+${countryCode.dialCode}";
                },
                onChanged: (phone) {
                  if (phone.number.length > 10) {
                    controller.phoneController.text = phone.number.substring(0, 10);
                    controller.phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.phoneController.text.length),
                    );
                  }
                  controller.validateForm();
                   controller.phoneController.text = phone.number;
                },
              ),
              // CustomTextField(
              //   controller: controller.phoneController,
              //   hintText: '+92 000000000',
              //   prefixIcon: Icons.phone_outlined,
              //   keyboardType: TextInputType.phone,
              //   validator: controller.validatePhone,
              // ),
              SizedBox(height: 10),

              CustomTextField(
                controller: controller.dobTEC,
                hintText: 'Date of birth',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () async {
                  DatePickerBdaya.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime(1900, 3, 5),
                    maxTime: DateTime(2006, 12, 31),
                    onConfirm: (date) {
                      controller.dobController.value = date;
                      controller.dobTEC.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(date);
                      controller.update();
                    },
                    currentTime: DateTime.now(),
                    locale: LocaleType.en,
                  );
                },
                // onTap: () => controller.selectDateOfBirth(context),
                validator: (value) =>
                    controller.validateRequired(value, 'Date of birth'),
              ),
              SizedBox(height: 10),

              Obx(
                () => CustomTextField(
                  controller: controller.passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  validator: controller.validatePassword,
                ),
              ),
              SizedBox(height: 10),

              GenderSelector(controller: controller),
              SizedBox(height: 10),

              Obx(
                () => CustomButton(
                  text: "Next",
                  isLoading: controller.isLoading.value,
                  onPressed: () {

                      if (controller.formKey.currentState!.validate()) {
                        if (controller.isFormValid.value) {
                          // Store the values in observable variables before navigation
                          debugPrint("=== Moving to Basic Info ===");
                          debugPrint("Email saved: ${controller.emailController.value}");
                          debugPrint("First Name saved: ${controller.firstNameController.value}");
                          debugPrint("Last Name saved: ${controller.lastNameController.value}");


                        // Get.toNamed(AppRoutes.BASIC_INFO);
                        Get.to(
                                () => const BasicInfoView());
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCheckbox(
                    value: true,
                    onChanged: (bool value) {
                      debugPrint('$value');
                      controller.isTermsAgree.value = value;
                      controller.update();
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.visible,
                      text: TextSpan(
                        text: 'By creating an account, You agree to the',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w400,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(AppRoutes.IN_APP_WEB_VIEW_SITE_TERMS_AND_CONDITIONS);
                              },
                            text: ' Terms & Conditions ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'and',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(AppRoutes.IN_APP_WEB_VIEW_SITE);
                              },
                            text: ' Privacy Policy.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
