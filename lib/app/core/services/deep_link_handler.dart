// deep_link_handler.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import '../models/res_model/profile_details.dart';
import '../routes/app_routes.dart';
import '../../viewmodels/user_details_viewmodel.dart';

class DeepLinkHandler {
  static late AppLinks _appLinks;
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _isHandlingDeepLink = false;
  static String? _pendingDeepLinkProfileId; // Store pending deep link

  static Future<void> initDeepLinks() async {
    debugPrint('🔗 Initializing deep links...');
    _appLinks = AppLinks();

    // Handle initial link when app opens from a deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('🔗 Initial deep link detected: $initialLink');
        // Store the pending deep link for later processing
        final profileId = _extractProfileId(initialLink.toString());
        if (profileId != null) {
          _pendingDeepLinkProfileId = profileId;
          debugPrint('📌 Stored pending profile ID: $profileId');
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to get initial link: $e');
    }

    // Handle links when app is already open
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('🔗 New deep link received while app is open: $uri');
      _handleDeepLink(uri.toString());
    }, onError: (err) {
      debugPrint('❌ Error in link stream: $err');
    });
  }

  // New method to process pending deep links after app is ready
  static void processPendingDeepLink() {
    if (_pendingDeepLinkProfileId != null) {
      debugPrint('🔄 Processing pending deep link for profile: $_pendingDeepLinkProfileId');
      final profileId = _pendingDeepLinkProfileId!;
      _pendingDeepLinkProfileId = null; // Clear the pending link

      // Check current route to determine navigation strategy
      final currentRoute = Get.currentRoute;
      debugPrint('📍 Processing deep link from route: $currentRoute');

      if (currentRoute == AppRoutes.BOTTOM_NAV ||
          currentRoute.contains('/bottom-nav')) {
        // Already on bottom nav, just navigate to profile
        Get.toNamed(
          AppRoutes.USER_DETAILS_VIEW,
          arguments: profileId,
        );
      } else {
        // Need to create proper stack
        _navigateToProfileWithStack(profileId);
      }
    }
  }

  static String? _extractProfileId(String link) {
    try {
      final uri = Uri.parse(link);
      String? profileId;

      // Handle different URL patterns
      if (uri.scheme == 'https' && uri.host == 'asaanrishta.com') {
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'user-details-view') {
          profileId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
      }
      else if (uri.scheme == 'assaanrishta' || uri.scheme == 'asaanrishta') {
        if (uri.host == 'user-details-view') {
          profileId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        }
        else if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'user-details-view') {
          profileId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
        else if (uri.pathSegments.isNotEmpty) {
          profileId = uri.pathSegments[0];
        }
      }

      return profileId;
    } catch (e) {
      debugPrint('❌ Error extracting profile ID: $e');
      return null;
    }
  }

  static void _handleDeepLink(String link) {
    // Prevent multiple simultaneous deep link handling
    if (_isHandlingDeepLink) {
      debugPrint('⚠️ Already handling a deep link, skipping...');
      return;
    }

    _isHandlingDeepLink = true;
    debugPrint('📱 Processing deep link: $link');

    try {
      final profileId = _extractProfileId(link);

      if (profileId != null && profileId.isNotEmpty) {
        debugPrint('✅ Profile ID extracted: $profileId');
        _navigateToProfile(profileId);
      } else {
        debugPrint('⚠️ No valid profile ID found in link');
      }
    } catch (e) {
      debugPrint('❌ Error handling deep link: $e');
    } finally {
      // Reset flag after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingDeepLink = false;
      });
    }
  }

  // Navigate with proper stack for terminated mode
  static void _navigateToProfileWithStack(String profileId) {
    debugPrint('🚀 Creating navigation stack for profile: $profileId');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        final currentRoute = Get.currentRoute;

        debugPrint('📍 Current route when creating stack: $currentRoute');

        // Check if we're still on splash, auth screens, or initial routes
        if (currentRoute == AppRoutes.SPLASH ||
            currentRoute == AppRoutes.ACCOUNT_TYPE ||
            currentRoute == AppRoutes.LOGIN ||
            currentRoute == '/' ||
            currentRoute.isEmpty) {

          debugPrint('📱 App just started or on auth screen, creating proper navigation stack...');

          // First navigate to home/bottom nav (this replaces splash/auth screens)
         // Get.offAllNamed(AppRoutes.BOTTOM_NAV);
          Get.offAllNamed(AppRoutes.SPLASH);

          // Then push the profile view on top after a delay
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.toNamed(
              AppRoutes.USER_DETAILS_VIEW,
              arguments: profileId,
            );
            debugPrint('✅ Navigation stack created: BottomNav -> UserDetails($profileId)');
          });
        } else if (currentRoute == AppRoutes.BOTTOM_NAV ||
            currentRoute.contains('/bottom-nav')) {
          // Already on bottom nav, just navigate to profile
          debugPrint('📱 Already on BottomNav, navigating to profile...');
          Get.toNamed(
            AppRoutes.USER_DETAILS_VIEW,
            arguments: profileId,
          );
        } else {
          // App is already running on some other screen, use normal navigation
          _navigateToProfile(profileId);
        }
      });
    });
  }

  static void _navigateToProfile(String profileId) {
    debugPrint('🚀 Navigating to profile: $profileId');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final String currentRoute = Get.currentRoute;

        try {
          debugPrint('🔄 Current route before navigation: $currentRoute');
          debugPrint('🔄 Navigating with profile ID: $profileId');

          // Check if we're on splash or auth screens (app just opened)
          if (currentRoute == AppRoutes.SPLASH ||
              currentRoute == AppRoutes.LOGIN ||
              currentRoute == AppRoutes.ACCOUNT_TYPE ||
              currentRoute == '/' ||
              currentRoute.isEmpty) {

            // Create proper navigation stack
            debugPrint('📱 Creating navigation stack from auth/splash screen...');

            // Navigate to bottom nav first, then to profile
            Get.offAllNamed(AppRoutes.BOTTOM_NAV);

            Future.delayed(const Duration(milliseconds: 300), () {
              Get.toNamed(
                AppRoutes.USER_DETAILS_VIEW,
                arguments: profileId,
              );
            });

            _isHandlingDeepLink = false;
            return;
          }

          // Check if already on user-details-view
          if (currentRoute.contains('/user-details-view')||currentRoute.startsWith('/user-details-view/')) {
            debugPrint('📍 Already on user-details-view, checking controller...');

            if (Get.isRegistered<UserDetailsController>()) {
              final controller = Get.find<UserDetailsController>();

              // Check if it's the same profile
              if (controller.receiverId.value == profileId) {
                debugPrint('✅ Already viewing profile: $profileId. No action needed.');
                _isHandlingDeepLink = false;
                return;
              }

              // Different profile - replace the route
              debugPrint('🔄 Different profile detected. Replacing route...');

              // Close any open snackbars/dialogs
              if (Get.isSnackbarOpen) {
                Get.closeCurrentSnackbar();
              }
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }

              // Use offNamed to replace the current route
              Get.offNamed(
                AppRoutes.USER_DETAILS_VIEW,
                arguments: profileId,
                preventDuplicates: false,
              );
              controller.receiverId.value = profileId;
              controller.profileDetails.value = ProfileDetails(); // Reset profile data
              controller.videoController?.dispose(); // Dispose video if exists
              controller.videoController = null;
              controller.getProfileDetails(); // Reload with new ID

              // Force rebuild the view
              controller.update();
              debugPrint('✅ Route replaced with new profile: $profileId');
              _isHandlingDeepLink = false;
              return;
            }
          }

          // Navigate normally from other screens (home, etc.)
          if (currentRoute == AppRoutes.BOTTOM_NAV ||currentRoute == AppRoutes.BOTTOM_NAV2 ||
              currentRoute == AppRoutes.HOME ||
              currentRoute.contains('/bottom-nav')) {
            Get.toNamed(
              AppRoutes.USER_DETAILS_VIEW,
              arguments: profileId,
            );
            debugPrint('🔄 Navigated to profile from home/bottom nav');
          } else {
            // For any other route, just navigate
            Get.toNamed(
              AppRoutes.USER_DETAILS_VIEW,
              arguments: profileId,
            );
            debugPrint('🔄 Navigated to profile from: $currentRoute');
          }

          _isHandlingDeepLink = false;
          debugPrint('✅ Navigation completed for profile: $profileId');

        } catch (e) {
          debugPrint('❌ Error during navigation: $e');
          _isHandlingDeepLink = false;

          // Fallback: Create proper stack
          try {
            Get.offAllNamed(AppRoutes.BOTTOM_NAV);
            Future.delayed(const Duration(milliseconds: 300), () {
              Get.toNamed(
                AppRoutes.USER_DETAILS_VIEW,
                arguments: profileId,
              );
            });
            debugPrint('✅ Fallback navigation successful');
          } catch (fallbackError) {
            debugPrint('❌ Fallback navigation also failed: $fallbackError');
          }
        } finally {
          // Ensure flag is reset
          Future.delayed(const Duration(seconds: 1), () {
            _isHandlingDeepLink = false;
          });
        }
      });
    });
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }
}