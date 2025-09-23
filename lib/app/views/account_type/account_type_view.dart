// account_type_view.dart me auto-login check add karo
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/export.dart';
import '../../utils/exports.dart';
import '../../viewmodels/account_type_viewmodel.dart';
import '../../widgets/export.dart';


class AccountTypeView extends GetView<AccountTypeViewModel> {
  const AccountTypeView({super.key});


  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountTypeViewModel>(
      initState: (_) {
        Get.put(AccountTypeViewModel());
      },
      builder: (controller) => PopScope(
        canPop: true, // Allow back navigation
        onPopInvoked: (didPop) {
          if (didPop) {
            // User can go back - this will take them to previous page
            debugPrint('🔙 User navigated back from Account Type');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          // appBar: AppBar(
          //   backgroundColor: Colors.white,
          //   elevation: 0,
          //   systemOverlayStyle: SystemUiOverlayStyle.dark,
          //   toolbarHeight: 44,
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back, color: Colors.black87),
          //     onPressed: () {
          //       Get.back(); // Allow manual back navigation
          //     },
          //   ),
          // ),
          body: _buildAccountTypeContent(),
        ),
      ),
    );
  }



  Widget _buildAccountTypeContent() {
    return  SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            // Logo and App Name
            ImageHelper(
              image: AppAssets.appLogoPng,
              imageType: ImageType.asset,
              height: 270,
            ),
            Column(
              children: [
                const AppText(
                  text: "Account Type",
                  color: AppColors.blackColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 05),
                AppText(
                  text: "Please register or sign in to continue",
                  color: AppColors.fontLightColor.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: "Create an account",
                  isGradient: true,
                  fontColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  onTap: () => controller.navigateToSignup(),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "Login",
                  isGradient: false,
                  fontColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  onTap: () => controller.navigateToLogin(),
                ),
              ],
            ),

            // Create Account Button

            const SizedBox(height: 15),

            // Skip/Continue as Guest Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: controller.continueAsGuest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Continue as Guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
            // Terms and Conditions
            // Padding(
            //   padding: const EdgeInsets.only(top: 40, bottom: 40),
            //   child: RichText(
            //     textAlign: TextAlign.center,
            //     text: TextSpan(
            //       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            //       children: const [
            //         TextSpan(text: 'By creating an account, You agree to our '),
            //         TextSpan(
            //           recognizer: TapGestureRecognizer()
            //             ..onTap = () {
            //               Get.toNamed(AppRoutes.IN_APP_WEB_VIEW_SITE_TERMS_AND_CONDITIONS);
            //             },
            //           text: 'Terms & Conditions',
            //           style: TextStyle(color: Colors.pink, decoration: TextDecoration.underline),
            //         ),
            //         TextSpan(text: ' and agree to '),
            //         TextSpan(
            //           recognizer: TapGestureRecognizer()
            //             ..onTap = () {
            //               Get.toNamed(AppRoutes.IN_APP_WEB_VIEW_SITE);
            //             },
            //           text: 'Privacy Policy',
            //           style: TextStyle(color: Colors.pink, decoration: TextDecoration.underline),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ));
  }


}