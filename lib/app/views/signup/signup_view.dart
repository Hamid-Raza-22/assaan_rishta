import 'package:assaan_rishta/app/views/signup/widgets/custom_button.dart';
import 'package:assaan_rishta/app/views/signup/widgets/custom_text_field.dart';
import 'package:assaan_rishta/app/views/signup/widgets/gender_selector.dart';
import 'package:assaan_rishta/app/views/signup/widgets/profile_photo_picker.dart';
import 'package:assaan_rishta/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../widgets/app_text.dart';
import '../../widgets/custom_checkbox.dart';
import 'basic_info_view.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
class SignupView extends StatelessWidget {
  final SignupViewModel controller = Get.find<SignupViewModel>();

SignupView({super.key});

  _appBar() {
    return const PreferredSize(
      preferredSize: Size(double.infinity, 40),
      child: CustomAppBar(
        isBack: true,
        title: "Create Account",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                // child: Text(
                //   'Create Account',
                //   style: TextStyle(
                //     fontSize: 28,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
              ),
              SizedBox(height: 8),
              Center(
                child: AppText(
                  text: 'Sign up to keep exploring profiles\naround the world',
                  // style: TextStyle(
                  //   fontSize: 16,
                  //   color: Colors.grey[600],
                  //   height: 1.4,
                  // ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 25),

              // Profile Photo Picker
              Center(
                child: ProfilePhotoPicker(controller: controller),
              ),
              SizedBox(height: 20),

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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                cursorColor: AppColors.primaryColor,
                initialCountryCode: 'PK',
                disableLengthCheck: true, // Important: We handle validation ourselves
                validator: controller.validatePhone,
                onCountryChanged: (country) {
                  // Update country code (dial code) and ISO code separately
                  controller.countryCode.value = "+${country.dialCode}";
                  controller.countryISOCode.value = country.code;

                  // Get validation rule for the new country
                  final rule = controller.phoneValidationRules[country.code];
                  final maxLength = rule?.maxLength ?? 10;

                  // Clear phone field when country changes for better UX
                  controller.phoneController.clear();

                  // Re-validate the form
                  controller.validateForm();

                  // Optional: Show a snackbar with phone requirements
                  // if (rule != null) {
                  //   Get.snackbar(
                  //     'Phone Format',
                  //     rule.minLength == rule.maxLength
                  //         ? '${rule.countryName} requires ${rule.minLength} digits'
                  //         : '${rule.countryName} requires ${rule.minLength}-${rule.maxLength} digits',
                  //     snackPosition: SnackPosition.BOTTOM,
                  //     duration: const Duration(seconds: 3),
                  //     backgroundColor: AppColors.primaryColor.withOpacity(0.9),
                  //     colorText: Colors.white,
                  //     margin: const EdgeInsets.all(10),
                  //     borderRadius: 8,
                  //   );
                  // }
                },
                onChanged: (phone) {
                  // Get validation rule for current country
                  final rule = controller.phoneValidationRules[controller.countryCode.value];
                  final maxLength = rule?.maxLength ?? 10;

                  // Limit input based on country's maximum length
                  if (phone.number.length > maxLength) {
                    // Trim the input to max length
                    controller.phoneController.text = phone.number.substring(0, maxLength);
                    controller.phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.phoneController.text.length),
                    );

                    // Show feedback when max length reached
                    HapticFeedback.lightImpact(); // Optional: Add haptic feedback
                  } else {
                    controller.phoneController.text = phone.number;
                  }

                  // Validate form on every change
                  controller.validateForm();
                },
              ),              // CustomTextField(
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
                    maxTime: DateTime(DateTime.now().year - 18, 12, 31),
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
                    debugPrint("Mobile Number: ${controller.phoneController.text}");
                    debugPrint("Mobile Number: ${controller.countryCode}${controller.phoneController.text.trim()}");
                    
                    // Check if profile photo is selected
                    if (controller.profilePhoto.value == null) {
                      controller.photoError.value = 'Profile photo is required';
                      Get.snackbar(
                        'Photo Required',
                        'Please add a profile photo to continue',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.shade100,
                        colorText: Colors.red.shade800,
                        margin: const EdgeInsets.all(10),
                        borderRadius: 8,
                        duration: const Duration(seconds: 3),
                      );
                      return;
                    }
                    
                    if (controller.formKey.currentState!.validate()) {
                      if (controller.isFormValid.value) {
                        // Store the values in observable variables before navigation
                        debugPrint("=== Moving to Basic Info ===");
                        debugPrint("Email saved: ${controller.emailController.value}");
                        debugPrint("First Name saved: ${controller.firstNameController.value}");
                        debugPrint("Last Name saved: ${controller.lastNameController.value}");

                        // Get.toNamed(AppRoutes.BASIC_INFO);
                        Get.to(() => const BasicInfoView());
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
