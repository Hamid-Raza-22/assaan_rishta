import 'dart:async';

import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:assaan_rishta/app/core/services/deep_link_handler.dart';
import 'package:assaan_rishta/app/core/utils/developer_mode_checker.dart';
import 'package:assaan_rishta/app/viewmodels/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/base/export.dart';
import '../../domain/export.dart';

class SplashController extends BaseController {
  UserManagementUseCase useCase;

  SplashController(this.useCase);

  @override
  void onInit() async {
    super.onInit();
    _handleNavigation();
  }

  void _handleNavigation() async {
    // Wait for splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));

    // CRITICAL: Check Developer Mode FIRST - Block app if enabled
    // if (kReleaseMode || kProfileMode) {
    //   await _checkDeveloperModeBlocking();
    // }
    // CRITICAL: Wait for AuthService to complete email verification
    // AuthService is already running in parallel since app start (Get.put in AppBindings)
    final authService = Get.find<AuthService>();
    debugPrint('⏳ Waiting for auth verification to complete...');
    
    // Wait for auth service to initialize (max 5 seconds - should be faster now)
    int attempts = 0;
    while (!authService.isInitialized.value && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    if (!authService.isInitialized.value) {
      debugPrint('⚠️ Auth verification timeout - defaulting to logged out');
    }
    
    debugPrint('✅ Auth verification completed in ${attempts * 100}ms. Initialized: ${authService.isInitialized.value}');

    // Check auth status AFTER verification completes
    bool isLoggedIn = authService.isUserLoggedIn.value;
    
    debugPrint('🔑 User logged in status: $isLoggedIn');

    if (isLoggedIn) {
      // If logged in, check Firestore flag whether partner preference is updated
      try {
        final uid = authService.userId;
        if (uid == null) {
          debugPrint('⚠️ User ID is null after login - going to account type');
          Get.offNamed(AppRoutes.ACCOUNT_TYPE);
          return;
        }
        
        final doc = await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(uid.toString())
            .get();

        final data = doc.data();
        final bool isPreferenceUpdated =
            data != null && (data['is_preference_updated'] == true);

        if (isPreferenceUpdated) {
          debugPrint('🏠 Navigating to Home');
          Get.offNamed(AppRoutes.BOTTOM_NAV);
        } else {
          debugPrint('⚙️ Navigating to Partner Preference');
          Get.offNamed(AppRoutes.PARTNER_PREFERENCE_VIEW);
        }
      } catch (e) {
        debugPrint('❌ Error checking preference: $e');
        // Fallback to home on any error
        Get.offNamed(AppRoutes.BOTTOM_NAV);
      }

      // Process any pending deep links after navigation
      // This ensures proper navigation stack
      Future.delayed(const Duration(milliseconds: 500), () {
        DeepLinkHandler.processPendingDeepLink();
      });
    } else {
      debugPrint('📝 User not logged in - going to account type');
      // For non-logged in users, check if there's a pending deep link
      // If yes, it will handle navigation, otherwise go to account type

      // Try to process pending deep link first
      DeepLinkHandler.processPendingDeepLink();

      // If no deep link was processed (still on splash), go to account type
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.currentRoute == AppRoutes.SPLASH || Get.currentRoute == '/') {
          Get.offNamed(AppRoutes.ACCOUNT_TYPE);
        }
      });
    }
  }

  /// Check developer mode and BLOCK app from proceeding
  /// App will NOT move from splash until developer mode is disabled
  Future<void> _checkDeveloperModeBlocking() async {
    debugPrint('🔍 Checking developer mode before proceeding...');
    
    bool isDeveloperMode = await DeveloperModeChecker.isDeveloperModeEnabled();
    
    if (isDeveloperMode) {
      debugPrint('⚠️ Developer mode enabled - BLOCKING app at splash screen');
      
      // Show blocking dialog
      DeveloperModeChecker.showDeveloperModeDialog();
      
      // Keep checking every 2 seconds until developer mode is OFF
      while (isDeveloperMode) {
        await Future.delayed(const Duration(seconds: 2));
        isDeveloperMode = await DeveloperModeChecker.isDeveloperModeEnabled();
        
        if (!isDeveloperMode) {
          debugPrint('✅ Developer mode disabled - closing dialog and continuing');
          // Close the dialog
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          break;
        } else {
          debugPrint('⏳ Still waiting for developer mode to be disabled...');
        }
      }
    } else {
      debugPrint('✅ Developer mode not enabled - proceeding normally');
    }
  }
}