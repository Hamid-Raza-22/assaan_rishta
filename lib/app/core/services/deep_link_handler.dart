// optimized_deep_link_handler.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import '../../views/vendor/details/vender_detail_controller.dart';
import '../models/res_model/profile_details.dart';
import '../models/res_model/all_vendors_list.dart';
import '../routes/app_routes.dart';
import '../../viewmodels/user_details_viewmodel.dart';
import '../../domain/export.dart';

class DeepLinkHandler {
  static late AppLinks _appLinks;
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _isHandlingDeepLink = false;
  static String? _pendingDeepLinkProfileId;
  static String? _pendingDeepLinkVendorId;
  static String? _pendingDeepLinkType;

  // Cache for vendor data to avoid repeated API calls
  static final Map<String, VendorsList> _vendorCache = {};
  static DateTime? _cacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  static Future<void> initDeepLinks() async {
    debugPrint('🔗 Initializing optimized deep links...');
    _appLinks = AppLinks();

    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('🔗 Initial deep link detected: $initialLink');
        _processInitialLink(initialLink.toString());
      }
    } catch (e) {
      debugPrint('❌ Failed to get initial link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('🔗 New deep link received: $uri');
      _handleDeepLink(uri.toString());
    }, onError: (err) {
      debugPrint('❌ Error in link stream: $err');
    });
  }

  static void _processInitialLink(String link) {
    if (link.contains('user-details-view')) {
      final profileId = _extractProfileId(link);
      if (profileId != null) {
        _pendingDeepLinkProfileId = profileId;
        _pendingDeepLinkType = 'user';
        debugPrint('📌 Stored pending user profile ID: $profileId');
      }
    } else if (link.contains('vendor-details-view')) {
      final vendorId = _extractVendorId(link);
      if (vendorId != null) {
        _pendingDeepLinkVendorId = vendorId;
        _pendingDeepLinkType = 'vendor';
        debugPrint('📌 Stored pending vendor ID: $vendorId');
      }
    }
  }

  static void processPendingDeepLink() {
    if (_pendingDeepLinkType == 'user' && _pendingDeepLinkProfileId != null) {
      final profileId = _pendingDeepLinkProfileId!;
      _pendingDeepLinkProfileId = null;
      _pendingDeepLinkType = null;
      _navigateToProfile(profileId);
    } else if (_pendingDeepLinkType == 'vendor' && _pendingDeepLinkVendorId != null) {
      final vendorId = _pendingDeepLinkVendorId!;
      _pendingDeepLinkVendorId = null;
      _pendingDeepLinkType = null;
      _fetchAndNavigateToVendorOptimized(vendorId);
    }
  }

  static String? _extractProfileId(String link) {
    try {
      final uri = Uri.parse(link);
      String? profileId;

      if (uri.scheme == 'https' && uri.host == 'asaanrishta.com') {
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'user-details-view') {
          profileId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
      } else if (uri.scheme == 'asaanrishta') {
        if (uri.host == 'user-details-view') {
          profileId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        } else if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'user-details-view') {
          profileId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
      }

      return profileId;
    } catch (e) {
      debugPrint('❌ Error extracting profile ID: $e');
      return null;
    }
  }

  static String? _extractVendorId(String link) {
    try {
      final uri = Uri.parse(link);
      String? vendorId;

      if (uri.scheme == 'https' && uri.host == 'asaanrishta.com') {
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'vendor-details-view') {
          vendorId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
      } else if (uri.scheme == 'asaanrishta') {
        if (uri.host == 'vendor-details-view') {
          vendorId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        } else if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'vendor-details-view') {
          vendorId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
      }

      return vendorId;
    } catch (e) {
      debugPrint('❌ Error extracting vendor ID: $e');
      return null;
    }
  }

  static void _handleDeepLink(String link) {
    if (_isHandlingDeepLink) {
      debugPrint('⚠️ Already handling a deep link, skipping...');
      return;
    }

    _isHandlingDeepLink = true;
    debugPrint('📱 Processing deep link: $link');

    try {
      if (link.contains('vendor-details-view')) {
        final vendorId = _extractVendorId(link);
        if (vendorId != null && vendorId.isNotEmpty) {
          debugPrint('✅ Vendor ID extracted: $vendorId');

          // Check if already viewing this vendor
          if (_isAlreadyViewingVendor(vendorId)) {
            debugPrint('✅ Already viewing vendor $vendorId, no action needed');
            _isHandlingDeepLink = false;
            return;
          }

          _fetchAndNavigateToVendorOptimized(vendorId);
        } else {
          debugPrint('⚠️ No valid vendor ID found in link');
          _isHandlingDeepLink = false;
        }
      } else if (link.contains('user-details-view')) {
        final profileId = _extractProfileId(link);
        if (profileId != null && profileId.isNotEmpty) {
          debugPrint('✅ Profile ID extracted: $profileId');

          // Check if already viewing this profile
          if (_isAlreadyViewingProfile(profileId)) {
            debugPrint('✅ Already viewing profile $profileId, no action needed');
            _isHandlingDeepLink = false;
            return;
          }

          _navigateToProfile(profileId);
        } else {
          debugPrint('⚠️ No valid profile ID found in link');
          _isHandlingDeepLink = false;
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling deep link: $e');
      _isHandlingDeepLink = false;
    }
  }

  // Helper method to check if already viewing the same vendor
  static bool _isAlreadyViewingVendor(String vendorId) {
    try {
      final currentRoute = Get.currentRoute;
      debugPrint('🔍 Current route for vendor check: $currentRoute');

      // Check if we're on any vendor details route
      if (currentRoute.contains('/vendor-details-view') ||
          currentRoute.contains('/vender-details-view') ||
          currentRoute == AppRoutes.VENDER_DETAILS_VIEW) {

        debugPrint('🔍 On vendor details route, checking controller...');

        // Check standard controller
        if (Get.isRegistered<VendorDetailController>()) {
          final controller = Get.find<VendorDetailController>();
          final currentVendorId = controller.vendorsItem?.venderID?.toString();
          debugPrint('🔍 Controller vendor ID: $currentVendorId vs target: $vendorId');

          if (currentVendorId == vendorId) {
            debugPrint('✅ Same vendor already loaded in controller');
            return true;
          }
        }
      }

      debugPrint('❌ Different vendor or not on vendor route');
      return false;
    } catch (e) {
      debugPrint('❌ Error checking current vendor: $e');
      return false;
    }
  }

  // Helper method to check if already viewing the same profile
  static bool _isAlreadyViewingProfile(String profileId) {
    try {
      final currentRoute = Get.currentRoute;

      if (currentRoute.contains('/user-details-view')) {
        if (Get.isRegistered<UserDetailsController>()) {
          final controller = Get.find<UserDetailsController>();
          final currentProfileId = controller.receiverId.value;
          return currentProfileId == profileId;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error checking current profile: $e');
      return false;
    }
  }

  // OPTIMIZED VENDOR FETCHING WITH CACHING AND PARALLEL REQUESTS
  static Future<void> _fetchAndNavigateToVendorOptimized(String vendorId) async {
    try {
      debugPrint('🚀 Optimized vendor fetch for ID: $vendorId');

      // Check cache first
      if (_isCacheValid() && _vendorCache.containsKey(vendorId)) {
        debugPrint('⚡ Using cached vendor data');
        final cachedVendor = _vendorCache[vendorId]!;
        _navigateToVendor(cachedVendor);
        _isHandlingDeepLink = false;
        return;
      }

      // Show minimal loading indicator
      _showMinimalLoader();

      final userManagementUseCases = Get.find<UserManagementUseCase>();
      final List<int> categoryIds = [10, 6, 4, 8, 5, 11, 12, 3, 9];

      // Create parallel API calls for all categories
      final List<Future> futures = categoryIds.map((catId) async {
        try {
          final response = await userManagementUseCases.getAllVendors(
            catId: catId,
            pageNo: "1",
            cityId: 0,
          );

          return response.fold(
                (error) => null,
                (success) {
              if (success.profilesList != null && success.profilesList!.isNotEmpty) {
                try {
                  return success.profilesList!.firstWhere(
                        (v) => v.venderID.toString() == vendorId,
                  );
                } catch (e) {
                  return null;
                }
              }
              return null;
            },
          );
        } catch (e) {
          debugPrint('❌ Error in category $catId: $e');
          return null;
        }
      }).toList();

      // Wait for any future to complete with a result
      VendorsList? foundVendor;

      // Use a completer to get the first successful result
      final completer = Completer<VendorsList?>();
      int completedCount = 0;

      for (final future in futures) {
        future.then((result) {
          completedCount++;
          if (result != null && !completer.isCompleted) {
            completer.complete(result);
          } else if (completedCount == futures.length && !completer.isCompleted) {
            completer.complete(null);
          }
        });
      }

      // Wait for result with timeout
      foundVendor = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );

      _hideLoader();

      if (foundVendor != null) {
        debugPrint('✅ Vendor found: ${foundVendor.venderBusinessName}');

        // Cache the result
        _cacheVendor(vendorId, foundVendor);

        _navigateToVendor(foundVendor);
      } else {
        debugPrint('❌ Vendor not found with ID: $vendorId');
        _showVendorNotFoundError();
        _navigateToVendorsFallback();
      }

    } catch (e) {
      debugPrint('❌ Error in optimized vendor fetch: $e');
      _hideLoader();
      _showErrorAndFallback();
    } finally {
      _isHandlingDeepLink = false;
    }
  }

  static bool _isCacheValid() {
    return _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheExpiry;
  }

  static void _cacheVendor(String vendorId, VendorsList vendor) {
    _vendorCache[vendorId] = vendor;
    _cacheTime = DateTime.now();

    // Clean old cache entries to prevent memory issues
    if (_vendorCache.length > 50) {
      _vendorCache.clear();
      _cacheTime = DateTime.now();
    }
  }

  static void _showMinimalLoader() {
    if (Get.context != null && !Get.isSnackbarOpen) {
      Get.snackbar(
        '',
        '',
        titleText: const SizedBox.shrink(),
        messageText: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading vendor...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 10),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
      );
    }
  }

  static void _hideLoader() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static void _navigateToVendor(VendorsList vendor) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = Get.currentRoute;
      final vendorId = vendor.venderID.toString();

      try {
        debugPrint('🔍 Current route: $currentRoute');
        debugPrint('🔍 Target vendor ID: $vendorId');

        // IMPROVED: More comprehensive check for vendor details routes
        final isOnVendorRoute = currentRoute.contains('/vendor-details-view') ||
            currentRoute.contains('/vender-details-view') ||
            currentRoute == AppRoutes.VENDER_DETAILS_VIEW ||
            currentRoute.startsWith('/vendor-details-view/') ||
            currentRoute.startsWith('/vender-details-view/$vendorId');

        // Check if already on vendor details view
        if (isOnVendorRoute) {
          debugPrint('🔍 Already on vendor details view, checking controller...');

          if (Get.isRegistered<VendorDetailController>()) {
            final controller = Get.find<VendorDetailController>();
            final currentVendorId = controller.vendorsItem?.venderID?.toString();

            debugPrint('🔍 Current vendor ID in controller: $currentVendorId');

            // Check if it's the same vendor
            if (currentVendorId == vendorId) {
              debugPrint('✅ Already viewing vendor: ${vendor.venderBusinessName}. No navigation needed.');
              return; // CRITICAL: Return here to prevent any navigation
            }

            // Different vendor - update the existing controller
            debugPrint('🔄 Different vendor detected. Updating controller...');

            // Close any open snackbars/dialogs
            _hideLoader();

            // Update the existing controller with new vendor data
            controller.updateVendorData(vendor);
            debugPrint('✅ Controller updated with new vendor: ${vendor.venderBusinessName}');
            return; // CRITICAL: Return here to prevent navigation
          }
        }

        // Only navigate if we're not already on the correct vendor details page
        debugPrint('🚀 Navigating to vendor details...');

        // Navigate normally for other cases
        if (currentRoute == AppRoutes.SPLASH ||
            currentRoute == AppRoutes.LOGIN ||
            currentRoute == AppRoutes.ACCOUNT_TYPE ||
            currentRoute == '/' ||
            currentRoute.isEmpty) {

          debugPrint('🚀 App starting, creating navigation stack...');
          Get.offAllNamed(AppRoutes.BOTTOM_NAV);

          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toNamed(
              AppRoutes.VENDER_DETAILS_VIEW,
              arguments: vendor,
              preventDuplicates: true, // IMPROVED: Enable prevent duplicates
            );
            debugPrint('✅ Navigation completed from app start');
          });
        } else {
          debugPrint('🚀 Normal navigation to vendor details');

          // IMPROVED: Use offNamed to replace current route if it's also a vendor route
          if (isOnVendorRoute) {
            Get.offNamed(
              AppRoutes.VENDER_DETAILS_VIEW,
              arguments: vendor,
            );
            debugPrint('✅ Replaced vendor route');
          } else {
            Get.toNamed(
              AppRoutes.VENDER_DETAILS_VIEW,
              arguments: vendor,
              preventDuplicates: true,
            );
            debugPrint('✅ Normal navigation completed');
          }
        }

      } catch (e) {
        debugPrint('❌ Error during vendor navigation: $e');

        // Fallback: Create proper navigation stack
        try {
          Get.offAllNamed(AppRoutes.BOTTOM_NAV);
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toNamed(
              AppRoutes.VENDER_DETAILS_VIEW,
              arguments: vendor,
              preventDuplicates: true,
            );
          });
          debugPrint('✅ Fallback navigation successful');
        } catch (fallbackError) {
          debugPrint('❌ Fallback navigation also failed: $fallbackError');
        }
      }
    });
  }

  static void _showVendorNotFoundError() {
    Get.snackbar(
      'Vendor Not Found',
      'The vendor you are looking for could not be found.',
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  static void _showErrorAndFallback() {
    Get.snackbar(
      'Error',
      'Unable to load vendor details. Please try again.',
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
    _navigateToVendorsFallback();
  }

  static void _navigateToVendorsFallback() {
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.SPLASH ||
        currentRoute == AppRoutes.LOGIN ||
        currentRoute == '/' ||
        currentRoute.isEmpty) {
      Get.offAllNamed(AppRoutes.BOTTOM_NAV);
    }
  }



  static void clearCache() {
    _vendorCache.clear();
    _cacheTime = null;
    debugPrint('🗑️ Vendor cache cleared');
  }

  static void dispose() {
    _linkSubscription?.cancel();
    clearCache();
  }

  // Navigate with proper stack for terminated mode
  static void _navigateToProfileWithStack(String profileId) {
    debugPrint('🚀 Creating navigation stack for profile: $profileId');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        final currentRoute = Get.currentRoute;

        debugPrint('🔍 Current route when creating stack: $currentRoute');

        // Check if we're still on splash, auth screens, or initial routes
        if (currentRoute == AppRoutes.SPLASH ||
            currentRoute == AppRoutes.ACCOUNT_TYPE ||
            currentRoute == AppRoutes.LOGIN ||
            currentRoute == '/' ||
            currentRoute.isEmpty) {

          debugPrint('📱 App just started or on auth screen, creating proper navigation stack...');

          // First navigate to home/bottom nav (this replaces splash/auth screens)
          Get.offAllNamed(AppRoutes.BOTTOM_NAV);

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
            debugPrint('🔍 Already on user-details-view, checking controller...');

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
}