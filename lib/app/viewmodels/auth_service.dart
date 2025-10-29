// auth_service.dart - FIXED VERSION WITH NOTIFICATION HANDLING
import 'package:assaan_rishta/app/viewmodels/chat_list_viewmodel.dart';
import 'package:assaan_rishta/app/viewmodels/profile_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../core/services/firebase_service/export.dart';
import '../core/services/secure_storage_service.dart';
import '../core/utils/app_logger.dart';
import '../domain/use_cases/user_management_use_case/user_management_use_case.dart';
import '../views/bottom_nav/export.dart';
import 'chat_viewmodel.dart';

class AuthService extends GetxController {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= Get.find<AuthService>();

  // Observable states
  final RxBool isUserLoggedIn = false.obs;
  final RxBool isInitialized = false.obs;
  final Rx<UserData?> currentUser = Rx<UserData?>(null);

  // User data
  int? _userId;
  String? _userEmail;
  String? _userName;
  String? _userImage;

  // Getters
  int? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userImage => _userImage;

  @override
  void onInit() {
    super.onInit();
    _instance = this;
    checkAuthStatus();
  }

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    try {
      AppLogger.info('Checking authentication status...');
      final secureStorage = SecureStorageService();

      final isLoggedIn = await secureStorage.isUserLoggedIn();
      final userIdStr = await secureStorage.getUserId();
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
      final userEmail = await secureStorage.getUserEmail();
      final userName = await secureStorage.getUserName();
      final userImage = await secureStorage.getUserPic();

      if (isLoggedIn && userId != null && userId > 0) {
        // Set user data temporarily for verification and potential cleanup
        _userId = userId;
        _userEmail = userEmail;
        _userName = userName;
        _userImage = userImage;

        // Fast professional verification - check email first
        AppLogger.info('Verifying user profile for user ID: $userId');
        
        final profileExists = await _verifyUserProfileExists();

        if (!profileExists) {
          debugPrint('⚠️ User profile invalid (email null/empty). Force logout initiated.');
          // Await force logout to ensure navigation completes
          await _forceLogout();
          isInitialized.value = true; // Mark as initialized after logout
          return; // Stop here - don't proceed to home
        }

        // Profile exists and is valid
        isUserLoggedIn.value = true;
        currentUser.value = UserData(
          id: userId,
          email: userEmail ?? '',
          name: userName ?? '',
          image: userImage ?? '',
        );
        // ENHANCED: Initialize notification session
        //NotificationServices.initializeSession(userId.toString());
        // Update FCM token for logged in user
        await _updateFCMToken();

        AppLogger.success('User authenticated: $userName (ID: $userId)');

        // Navigate to home if on account type page
        if (Get.currentRoute == AppRoutes.ACCOUNT_TYPE) {
          Get.offAllNamed(AppRoutes.BOTTOM_NAV);
        }
      } else {
        isUserLoggedIn.value = false;
        currentUser.value = null;
        debugPrint('❌ No authenticated user found');
        // ENHANCED: Clear notification session
        NotificationServices.clearSession();
        debugPrint('❌ No authenticated user found');
      }
    } catch (e) {
      debugPrint('💥 Error checking auth status: $e');
      isUserLoggedIn.value = false;
      currentUser.value = null;
      NotificationServices.clearSession();
    } finally {
      isInitialized.value = true;
    }
  }

  // Login method
  Future<void> login({
    required int userId,
    required String email,
    required String name,
    required String image,
  }) async {
    try {
      debugPrint('🔑 Logging in user: $name (ID: $userId)');
      NotificationServices.clearSession();
      _userId = userId;
      _userEmail = email;
      _userName = name;
      _userImage = image;

      // Use secure storage for sensitive user data
      final secureStorage = SecureStorageService();
      await secureStorage.saveUserSession(
        userId: userId,
        email: email,
        name: name,
        pic: image,
      );

      isUserLoggedIn.value = true;
      currentUser.value = UserData(
        id: userId,
        email: email,
        name: name,
        image: image,
      );

      // ENHANCED: Initialize new notification session
      NotificationServices.initializeSession(userId.toString());
      // Update FCM token after login
      await _updateFCMToken();

      debugPrint('✅ Login successful');
    } catch (e) {
      debugPrint('💥 Error during login: $e');
      rethrow;
    }
  }

  // FIXED: Logout method with proper notification handling
  Future<void> logout(BuildContext context) async {
    try {
      AppLogger.lifecycle('Waiting for auth verification to complete...');
      NotificationServices.clearSession();

      // 1. Update Firebase status
      if (_userId != null) {
        await FirebaseService.updateActiveStatus(false);
        await FirebaseService.insideChatStatus(false);
      }

      // 2. Remove FCM token from Firestore
      await _removeFCMToken();

      // 3. Clear secure storage BUT preserve onboarding flags
      final secureStorage = SecureStorageService();
      
      // Save the onboarding status before clearing
      final hasSeenOnboarding = await secureStorage.hasSeenOnboarding();
      final isFirstInstall = await secureStorage.isFirstInstall();

      // Clear all data
      await secureStorage.clearAll();

      // Restore the onboarding flags
      await secureStorage.setHasSeenOnboarding(hasSeenOnboarding);
      await secureStorage.setFirstInstall(isFirstInstall);

      // 4. Reset local variables
      _userId = null;
      _userEmail = null;
      _userName = null;
      _userImage = null;

      // 5. Update observable states
      isUserLoggedIn.value = false;
      currentUser.value = null;
      await clearGetXInstances();

      // 6. Clear chat controller if exists
      if (Get.isRegistered<ChatViewModel>()) {
        final chatController = Get.find<ChatViewModel>();
        chatController.dispose();
      }

      AppLogger.success('Logout completed successfully');

      // 7. Navigate to login
      Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);

    } catch (e) {
      NotificationServices.clearSession();
      AppLogger.error('Error during logout: $e');

      // Even if there's an error, clear secure storage
      final secureStorage = SecureStorageService();
      
      // Save flags before clearing
      final hasSeenOnboarding = await secureStorage.hasSeenOnboarding();
      final isFirstInstall = await secureStorage.isFirstInstall();

      await secureStorage.clearAll();

      // Restore flags
      await secureStorage.setHasSeenOnboarding(hasSeenOnboarding);
      await secureStorage.setFirstInstall(isFirstInstall);

      isUserLoggedIn.value = false;
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);
    }
  }

  // Alternative method if you want to clear ALL GetX instances (use with caution)
  Future<void> clearGetXInstances() async {
    try {
      // This will delete all GetX controllers and clear the dependency tree
      // Clear specific controllers that might hold user data
      if (Get.isRegistered<ChatViewModel>()) {
        Get.delete<ChatViewModel>(force: true);
      }

      if (Get.isRegistered<BottomNavController>()) {
        Get.delete<BottomNavController>(force: true);
      }

      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
      }
      if (Get.isRegistered<ChatListController>()) {
        Get.delete<ChatListController>(force: true);
      }

      AppLogger.lifecycle('All GetX instances cleared');
    } catch (e) {
      AppLogger.error('Error clearing GetX instances: $e');
    }
  }

  // Update FCM token in Firestore
  Future<void> _updateFCMToken() async {
    try {
      if (_userId == null || _userId! <= 0) return;

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      AppLogger.lifecycle('Updating FCM token for user: $_userId');

      // Update token in Firestore
      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_userId.toString())
          .update({
        'push_token': fcmToken,
        'last_token_update': FieldValue.serverTimestamp(),
      });

      AppLogger.success('FCM token updated successfully');
    } catch (e) {
      AppLogger.error('Error updating FCM token: $e');
    }
  }

  // Remove FCM token from Firestore
  Future<void> _removeFCMToken() async {
    try {
      if (_userId == null || _userId! <= 0) return;

      AppLogger.lifecycle('Removing FCM token for user: $_userId');

      // Remove token from Firestore
      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_userId.toString())
          .update({
        'push_token': FieldValue.delete(),
        'last_token_update': FieldValue.serverTimestamp(),
      });

      // Also delete the token locally from FCM
      await FirebaseMessaging.instance.deleteToken();

      AppLogger.success('FCM token removed successfully');
    } catch (e) {
      AppLogger.error('Error removing FCM token: $e');
    }
  }

  // Fast professional verification - check email validity
  Future<bool> _verifyUserProfileExists() async {
    try {
      if (!Get.isRegistered<UserManagementUseCase>()) {
        AppLogger.lifecycle('UserManagementUseCase not registered yet');
        return true; // Assume user exists if use case not available
      }

      final userManagementUseCase = Get.find<UserManagementUseCase>();
      
      // Fast API call without timeout
      AppLogger.lifecycle('Fetching user profile from backend...');
      final response = await userManagementUseCase.getCurrentUserProfile();

      return response.fold(
        (error) {
          // If error code is 404 or user not found, return false immediately
          AppLogger.error('Profile verification failed: ${error.title} - ${error.description}');
          if (error.title == '404' || error.title == '401' || error.title == '403') {
            AppLogger.error('User not found in backend - Force logout required');
            return false;
          }
          // For other errors (network issues, etc.), assume user exists
          AppLogger.error('Network/other error - assuming user exists');
          return true;
        },
        (profile) {
          // CRITICAL: Fast check - if email is null or empty, user is invalid
          if (profile.email == null || profile.email!.isEmpty) {
            AppLogger.error('INVALID PROFILE: Email is null or empty - Force logout required');
            return false;
          }
          AppLogger.success('Profile valid - Email: ${profile.email}');
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Exception verifying profile: $e');
      // On exception, assume user exists to avoid false logouts
      return true;
    }
  }

  // Force logout without context (for automatic logout)
  Future<void> _forceLogout() async {
    try {
      debugPrint('🚪 Force logout initiated...');
      NotificationServices.clearSession();

      final currentUserId = _userId;
      debugPrint('🚪 Force logout initiated for user: $currentUserId');


      // Update Firebase status if possible
      if (_userId != null) {
        try {
          await FirebaseService.updateActiveStatus(false);
          await FirebaseService.insideChatStatus(false);
        } catch (e) {
          debugPrint('⚠️ Error updating Firebase status: $e');
        }
      }

      // Perform complete Firebase cleanup
      if (currentUserId != null) {
        try {
          await _performCompleteFirebaseCleanup(currentUserId.toString());
        } catch (e) {
          debugPrint('⚠️ Error performing Firebase cleanup: $e');
        }
      }

      // Remove FCM token
      try {
        await _removeFCMToken();
      } catch (e) {
        debugPrint('⚠️ Error removing FCM token: $e');
      }

      // Clear secure storage BUT preserve onboarding flags
      final secureStorage = SecureStorageService();
      
      // Save the onboarding status before clearing
      final hasSeenOnboarding = await secureStorage.hasSeenOnboarding();
      final isFirstInstall = await secureStorage.isFirstInstall();

      // Clear all data
      await secureStorage.clearAll();

      // Restore the onboarding flags
      await secureStorage.setHasSeenOnboarding(hasSeenOnboarding);
      await secureStorage.setFirstInstall(isFirstInstall);

      // Reset local variables
      _userId = null;
      _userEmail = null;
      _userName = null;
      _userImage = null;

      // Update observable states
      isUserLoggedIn.value = false;
      currentUser.value = null;

      await clearGetXInstances();

      debugPrint('✅ Force logout completed');

      // Ensure navigation happens
      await Future.delayed(const Duration(milliseconds: 100));
      Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);
      debugPrint('📍 Navigated to Account Type page');
    } catch (e) {
      debugPrint('💥 Error during force logout: $e');
      // Ensure we still navigate to login even on error
      isUserLoggedIn.value = false;
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);
    }
  }

  // Complete Firebase cleanup when user is automatically logged out (optimized)
  Future<void> _performCompleteFirebaseCleanup(String userId) async {
    try {
      debugPrint('🔥 Starting complete Firebase cleanup for user: $userId');

      final batch = FirebaseFirestore.instance.batch();

      // Step 1: Mark user as deleted (instead of immediate deletion)
      final userRef = FirebaseFirestore.instance.collection('Hamid_users').doc(userId);
      batch.update(userRef, {
        'account_deleted': true,
        'deleted_at': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Deleted User',
        'image': '', // Clear image
        'about': 'This account has been deleted',
        'is_online': false,
        'is_mobile_online': false,
        'is_web_online': false,
        'push_token': '', // Clear push token
      });

      // Step 2: Get all users who have this deleted user in their chat list
      final allUsersSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .get();

      for (var userDoc in allUsersSnapshot.docs) {
        if (userDoc.id == userId) continue; // Skip the deleted user

        // Check if this user has the deleted user in their my_users
        final myUsersRef = userDoc.reference.collection('my_users').doc(userId);
        final myUserDoc = await myUsersRef.get();

        if (myUserDoc.exists) {
          // Mark this chat as with deleted user
          batch.update(myUsersRef, {
            'user_deleted': true,
            'deletion_timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          });

          debugPrint('📱 Updated chat reference for user: ${userDoc.id}');
        }
      }

      // Step 3: Clean up user's own my_users collection
      final myUsersSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .collection('my_users')
          .get();

      for (var doc in myUsersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Step 4: Clean up deleted_chats collection
      final deletedChatsSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .collection('deleted_chats')
          .get();

      for (var doc in deletedChatsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Step 5: Update all active conversations to show deletion status
      final conversationsSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .where('participants', arrayContains: userId)
          .get();

      for (var chatDoc in conversationsSnapshot.docs) {
        // Add a system message about user deletion
        final systemMessageRef = chatDoc.reference
            .collection('messages')
            .doc(DateTime.now().millisecondsSinceEpoch.toString());

        batch.set(systemMessageRef, {
          'fromId': 'SYSTEM',
          'toId': '',
          'msg': 'This user has deleted their account',
          'type': 'system',
          'sent': DateTime.now().millisecondsSinceEpoch.toString(),
          'read': '',
        });
      }

      // Commit all changes
      await batch.commit();

      debugPrint('✅ Complete Firebase cleanup completed successfully');

    } catch (e) {
      debugPrint('❌ Error in Firebase cleanup: $e');
      // Don't rethrow - we still want to complete logout even if cleanup fails
    }
  }
}

// User data model
class UserData {
  final int id;
  final String email;
  final String name;
  final String image;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
  });
}

// Firebase Service class for status updates
class FirebaseService {
  static Future<void> updateActiveStatus(bool isActive) async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null || userId <= 0) return;

      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId.toString())
          .update({
        'is_online': isActive,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      debugPrint('Error updating active status: $e');
    }
  }

  static Future<void> insideChatStatus(bool isInside) async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null || userId <= 0) return;

      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId.toString())
          .update({
        'is_inside': isInside,
      });
    } catch (e) {
      debugPrint('Error updating inside chat status: $e');
    }
  }
}