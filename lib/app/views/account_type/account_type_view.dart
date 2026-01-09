// account_type_view.dart - Professional UI with Account Type Selection
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
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            debugPrint('🚫 Back navigation disabled on Account Type screen');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: _buildAccountTypeContent(context),
        ),
      ),
    );
  }

  Widget _buildAccountTypeContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo
              ImageHelper(
                image: AppAssets.appLogoPng,
                imageType: ImageType.asset,
                height: 165,
              ),

              
              // Title
              const AppText(
                text: "Select Account",
                color: AppColors.blackColor,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              AppText(
                text: "Choose how you want to continue",
                color: AppColors.fontLightColor.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              const SizedBox(height: 30),

              // Account Type Selection Buttons (Two Square Buttons)
              _buildAccountTypeSelector(),

              const SizedBox(height: 30),

              // Dynamic Action Buttons based on selection
              _buildActionButtons(),

              const SizedBox(height: 20),

              // Continue as Guest Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: controller.continueAsGuest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Row - User Guide & Contact Us
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.navigateToUserGuide(),
                        icon: const Icon(
                          Icons.menu_book_outlined,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                        label: const Text('User Guide'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.navigateToContactUs(),
                        icon: const Icon(
                          Icons.support_agent,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                        label: const Text('Contact Us'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Account Type Selector with two square buttons
  Widget _buildAccountTypeSelector() {
    return Obx(() => Row(
      children: [
        // Rishta User Button
        Expanded(
          child: _buildAccountTypeButton(
            title: "Rishta User",
            subtitle: "Find your match",
            icon: Icons.favorite_rounded,
            isSelected: controller.isRishtaUserSelected,
            onTap: () => controller.selectAccountType(AccountType.rishtaUser),
          ),
        ),
        const SizedBox(width: 16),
        // Matrimonial (Vendor) Button
        Expanded(
          child: _buildAccountTypeButton(
            title: "Matrimonial",
            subtitle: "Vendor account",
            icon: Icons.business_rounded,
            isSelected: controller.isMatrimonialSelected,
            onTap: () => controller.selectAccountType(AccountType.matrimonial),
          ),
        ),
      ],
    ));
  }

  /// Build individual account type button
  Widget _buildAccountTypeButton({
    required String title,
         String? subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: AspectRatio(
          aspectRatio: 1.0, // Square shape
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animated container
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              // Title
              AppText(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryColor : AppColors.blackColor,
              ),
              const SizedBox(height: 4),
              // Subtitle
              AppText(
                text: subtitle,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.fontLightColor.withOpacity(0.7),
              ),
              // const SizedBox(height: 6),
              // // Selection indicator
              // AnimatedContainer(
              //   duration: const Duration(milliseconds: 250),
              //   width: 20,
              //   height: 20,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: isSelected ? AppColors.primaryColor : Colors.transparent,
              //     border: Border.all(
              //       color: isSelected ? AppColors.primaryColor : Colors.grey[400]!,
              //       width: 2,
              //     ),
              //   ),
              //   child: isSelected
              //       ? const Icon(Icons.check, size: 13, color: Colors.white)
              //       : null,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build dynamic action buttons based on account type selection
  Widget _buildActionButtons() {
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: controller.isRishtaUserSelected
            ? _buildRishtaUserButtons()
            : _buildMatrimonialButtons(),
      );
    });
  }

  /// Rishta User: Login + Create Account buttons
  Widget _buildRishtaUserButtons() {
    return Column(
      key: const ValueKey('rishta_buttons'),
      children: [
        CustomButton(
          text: "Login",
          isGradient: true,
          fontColor: AppColors.whiteColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          onTap: () => controller.navigateToLogin(),
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: "Create Account",
          isGradient: false,
          backgroundColor: Colors.white,
          fontColor: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          borderColor: AppColors.primaryColor,
          onTap: () => controller.navigateToSignup(),
        ),
      ],
    );
  }

  /// Matrimonial: Login + Create Account buttons
  Widget _buildMatrimonialButtons() {
    return Column(
      key: const ValueKey('matrimonial_buttons'),
      children: [
        CustomButton(
          text: "Login",
          isGradient: true,
          fontColor: AppColors.whiteColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          onTap: () => controller.navigateToLogin(),
        ),
        // const SizedBox(height: 12),
        // CustomButton(
        //   text: "Create Account (Matrimonial)",
        //   isGradient: false,
        //   backgroundColor: Colors.white,
        //   fontColor: AppColors.primaryColor,
        //   fontWeight: FontWeight.w600,
        //   fontSize: 18,
        //   borderColor: AppColors.primaryColor,
        //   onTap: () => controller.navigateToMatrimonialSignup(),
        // ),
      ],
    );
  }
}
