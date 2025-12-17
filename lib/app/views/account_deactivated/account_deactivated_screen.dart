import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        'Your account has been deactivated.';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_off_rounded,
                    size: 60,
                    color: Colors.red.shade400,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const AppText(
                  text: 'Account Deactivated',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                AppText(
                  text: reason,
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Additional info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          text: 'You have been logged out from all devices. '
                              'Contact support if you believe this is an error.',
                          fontSize: 14,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Support contact
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const AppText(
                        text: 'Support: 03064727345',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Go to Login Button
                CustomButton(
                  text: 'Go to Login',
                  onTap: () => _navigateToLogin(),
                  backgroundColor: AppColors.primaryColor,
                  fontColor: Colors.white,
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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
