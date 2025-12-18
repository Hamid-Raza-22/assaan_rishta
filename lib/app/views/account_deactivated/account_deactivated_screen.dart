import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/account_status_service.dart';
import '../../utils/exports.dart';
import '../../widgets/app_text.dart';
import '../../widgets/custom_button.dart';

/// AccountDeactivatedScreen - Shown when user's account is deactivated
/// Displays deactivation message and provides option to go to login
class AccountDeactivatedScreen extends StatelessWidget {
  const AccountDeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get deactivation reason from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    final reason = arguments?['reason'] as String? ?? 
        'Your account has been deleted.';
        // 'Your account has been deactivated.';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  // const SizedBox(height: 60),
                  //
                  // // App Logo
                  // Image.asset(
                  //   AppAssets.appLogoPng,
                  //   height: 80,
                  //   width: 80,
                  // ),
                  //
                  const SizedBox(height: 40),
                  
                  // Deactivated Icon with gradient background
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.1),
                          AppColors.secondaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_off_rounded,
                        size: 50,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  const AppText(
                    text: 'Account Deleted',
                    // text: 'Account Deactivated',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Description
                  AppText(
                    text: reason,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.fontLightColor.withOpacity(0.5),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.fillFieldColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                text: 'Important Notice',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                text: 'You have been logged out from all devices. '
                                    'Contact support if you believe this is an error.',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.fontLightColor.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Support Contact Card
                  GestureDetector(
                    // onTap: () => _launchPhone('03064727345'),
                    onTap: () => openWhatsApp(phone: '03064727345'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.05),
                            AppColors.secondaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.secondaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              color: AppColors.whiteColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: 'Need Help?',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.fontLightColor,
                              ),
                              AppText(
                                text: '0306-4727345',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.primaryColor.withOpacity(0.5),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Go to Login Button
                  CustomButton(
                    text: 'Go to Login',
                    isGradient: true,
                    fontColor: AppColors.whiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    onTap: () => _navigateToLogin(),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
  Future<void> openWhatsApp({required String phone, String? message}) async {
    String cleanNumber = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final text = Uri.encodeComponent(message ?? 'Assalam-o-Alaikum, I need assistance regarding Asaan Rishta.');
    final whatsappUrl = Uri.parse("whatsapp://send?phone=$cleanNumber&text=$text");
    final whatsappWebUrl = Uri.parse("https://wa.me/$cleanNumber?text=$text");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
      return;
    }
    if (await canLaunchUrl(whatsappWebUrl)) {
      await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      return;
    }
    await Clipboard.setData(ClipboardData(text: phone));
    Get.snackbar(
      "WhatsApp not found",
      "Number copied: $phone",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }
  void _navigateToLogin() {
    // Reset the deactivation state
    if (Get.isRegistered<AccountStatusService>()) {
      AccountStatusService.instance.resetDeactivationState();
    }
    
    // Navigate to account type/login screen
    Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);
  }
}
