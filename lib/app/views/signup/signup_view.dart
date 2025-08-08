import 'package:assaan_rishta/app/views/signup/widgets/custom_button.dart';
import 'package:assaan_rishta/app/views/signup/widgets/custom_text_field.dart';
import 'package:assaan_rishta/app/views/signup/widgets/gender_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../widgets/custom_checkbox.dart';

class SignupView extends StatelessWidget {
  final SignupViewModel controller = Get.find<SignupViewModel>();

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

              CustomTextField(
                controller: controller.phoneController,
                hintText: '+92 000000000',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: controller.validatePhone,
              ),
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
                        debugPrint(
                            "Form is valid, proceeding to basic info");
                        debugPrint(
                          "Email: ${controller.emailController.text}",
                        );
                        debugPrint(
                          "Password: ${controller.passwordController.text}",
                        );
                        Get.toNamed(AppRoutes.BASIC_INFO);
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
