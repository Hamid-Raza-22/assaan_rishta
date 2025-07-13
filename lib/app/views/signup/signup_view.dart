import 'package:assaan_rishta/app/views/signup/widgets/custom_button.dart';
import 'package:assaan_rishta/app/views/signup/widgets/custom_text_field.dart';
import 'package:assaan_rishta/app/views/signup/widgets/gender_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/signup_viewmodel.dart';


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
                controller: controller.dobController,
                hintText: 'Date of birth',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => controller.selectDateOfBirth(context),
                validator: (value) =>
                    controller.validateRequired(value, 'Date of birth'),
              ),
              SizedBox(height: 10),

              Obx(() => CustomTextField(
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
              )),
              SizedBox(height: 10),

              GenderSelector(controller: controller),
              SizedBox(height: 10),

              Obx(() => CustomButton(
                text: "Let's Get Started",
                isLoading: controller.isLoading.value,
                onPressed: controller.isFormValid.value
                    ? controller.signUp
                    : null,
              )),
              SizedBox(height: 8),

              RichText(
                text: TextSpan(
                  text: 'By creating an account, You agree to our ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: ' and agree to ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
