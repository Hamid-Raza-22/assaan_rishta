import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:assaan_rishta/app/views/login/widgets/custom_button.dart';
import 'package:assaan_rishta/app/views/login/widgets/custom_checkbox.dart';
import 'package:assaan_rishta/app/views/login/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/app_text.dart';

class LoginView extends GetView<LoginViewModel> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Navigate to a specific route instead of default back
          Get.offNamed(AppRoutes.ACCOUNT_TYPE);
          return false;
        },// Prevents default back action
   child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Center(
              child: const AppText(
                        text: "Welcome Back!",
              color: AppColors.blackColor,
              fontSize: 32,
              fontWeight: FontWeight.w500,
                        ),
            ),
              const SizedBox(height: 05),
              Center(
                child: AppText(
                  text: "Please login to your account",
                  color: AppColors.fontLightColor.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 40),
              CustomTextField(
                controller: controller.emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Row(
                    children: [
                      CustomCheckbox(
                        isChecked: controller.rememberMe.value,
                        onChanged: controller.toggleRememberMe,
                      ),
                      SizedBox(width: 8),
                      Text('Remember me', style: TextStyle(fontSize: 14)),
                    ],
                  )),
                  GestureDetector(
                    onTap: () {
                      Get.snackbar('Forgot Password',
                          'Forgot password functionality will be implemented');
                    },
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 40),
              Obx(() => CustomButton(
                text: "Login",
                isLoading: controller.isLoading.value,
                onPressed: controller.isFormValid.value
                    ? () => controller.login(context)
                    : null,
              )),
              SizedBox(height: 200),
              // Obx(() => Row(
              //   children: [
              //     CustomCheckbox(
              //       isChecked: controller.agreeToTerms.value,
              //       onChanged: controller.toggleAgreeToTerms,
              //     ),
              //     SizedBox(width: 8),
              //     Expanded(
              //       child: RichText(
              //         text: TextSpan(
              //           text: 'I agree to the ',
              //           style: TextStyle(
              //               color: Colors.grey[600], fontSize: 14),
              //           children: [
              //             TextSpan(
              //               text: 'Terms & Conditions',
              //               style: TextStyle(color: Colors.red),
              //             ),
              //             TextSpan(
              //               text: ' and ',
              //               style: TextStyle(color: Colors.grey[600]),
              //             ),
              //             TextSpan(
              //               text: 'Privacy Policy',
              //               style: TextStyle(color: Colors.red),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // )),
              SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style:
                        TextStyle(color: Colors.grey[600], fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/signup');
                      },
                      child: Text('Register here',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
