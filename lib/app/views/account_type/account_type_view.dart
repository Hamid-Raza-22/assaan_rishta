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
        canPop: false, // Disable back navigation
        onPopInvoked: (didPop) {
          if (!didPop) {
            // Back button pressed but navigation blocked
            debugPrint('� Back navigation disabled on Account Type screen');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: _buildAccountTypeContent(),
        ),
      ),
    );
  }

  Widget _buildAccountTypeContent() {
    return SafeArea(
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
                  const SizedBox(height: 10),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: ()=> controller.navigateToUserGuide(),
                        icon: const Icon(
                          Icons.menu_book_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        label: const Text('User Guide'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  const SizedBox(height: 100),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.navigateToContactUs(),
                        icon: const Icon(
                          Icons.support_agent,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        label: const Text('Contact Us'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
