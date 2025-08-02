// account_type_view.dart me auto-login check add karo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../viewmodels/account_type_viewmodel.dart';
import '../../viewmodels/auth_service.dart';

class AccountTypeView extends GetView<AccountTypeViewModel> {
  const AccountTypeView({super.key});


// account_type_view.dart me auto-login check को safe banao
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          toolbarHeight: 44,
        ),
        body: Obx(() {
          try {
            final authService = AuthService.instance;

            // Show loading while checking auth status
            if (!authService.isInitialized.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    ),
                    SizedBox(height: 20),
                    Text('Checking login status...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            // Show account type selection if not logged in
            return _buildAccountTypeContent();
          } catch (e) {
            debugPrint('💥 Error in AccountTypeView build: $e');
            return _buildAccountTypeContent();
          }
        }),
      ),
    );
  }
  void _checkAutoLogin() {
    // This will be handled by AuthService automatically
    debugPrint('🔄 Account type view loaded, auth check in progress...');
  }

  Widget _buildAccountTypeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Logo and App Name
            Center(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.pink, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.favorite, color: Colors.pink, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asan Rishta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      Text(
                        'FIND MATCH EASILY, SPEND LIFE HAPPILY',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            const Text(
              'Account Type',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Please choose your account type',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 60),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.navigateToSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Create an account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),

            const SizedBox(height: 16),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),

            // Terms and Conditions
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 40),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  children: const [
                    TextSpan(text: 'By creating an account, You agree to our '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(color: Colors.pink, decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: ' and agree to '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Colors.pink, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}