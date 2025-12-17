import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../viewmodels/chat_list_viewmodel.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../views/bottom_nav/export.dart';
import '../utils/app_logger.dart';
import 'firebase_service/notification_service.dart';
import 'secure_storage_service.dart';

/// SessionManager - Centralized session management using GetX
/// Handles clearing all user data, tokens, cached sessions across the app
/// when account is deactivated or user logs out.
class SessionManager extends GetxService {
  static SessionManager get instance => Get.find<SessionManager>();

  // Observable state
  final RxBool isClearing = false.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.lifecycle('[SessionManager] Initialized');
  }

  /// Clear all session data - tokens, user data, cached sessions
  /// This is the main method called when account is deactivated
  Future<void> clearAllSessionData() async {
    if (isClearing.value) {
      AppLogger.lifecycle('[SessionManager] Already clearing, skipping...');
      return;
    }

    isClearing.value = true;
    AppLogger.lifecycle('[SessionManager] 🧹 Starting complete session cleanup...');

    try {
      // Execute cleanup operations in parallel for speed
      await Future.wait([
        _clearSecureStorage(),
        _clearSharedPreferences(),
        _clearFirebaseData(),
        _clearFCMToken(),
      ], eagerError: false);

      // Clear GetX controllers (must be done after storage operations)
      await _clearGetXControllers();

      // Clear notification session
      _clearNotificationSession();

      AppLogger.success('[SessionManager] ✅ Complete session cleanup finished');
    } catch (e) {
      AppLogger.error('[SessionManager] Error during session cleanup: $e');
    } finally {
      isClearing.value = false;
    }
  }

  /// Clear secure storage (tokens, user credentials)
  Future<void> _clearSecureStorage() async {
    try {
      AppLogger.lifecycle('[SessionManager] Clearing secure storage...');
      final secureStorage = SecureStorageService();

      // Preserve onboarding flags
      final hasSeenOnboarding = await secureStorage.hasSeenOnboarding();
      final isFirstInstall = await secureStorage.isFirstInstall();

      // Clear all secure data
      await secureStorage.clearAll();

      // Restore onboarding flags
      await Future.wait([
        secureStorage.setHasSeenOnboarding(hasSeenOnboarding),
        secureStorage.setFirstInstall(isFirstInstall),
      ]);

      AppLogger.success('[SessionManager] Secure storage cleared');
    } catch (e) {
      AppLogger.error('[SessionManager] Error clearing secure storage: $e');
    }
  }

  /// Clear shared preferences
  Future<void> _clearSharedPreferences() async {
    try {
      AppLogger.lifecycle('[SessionManager] Clearing shared preferences...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      await prefs.clear();
      AppLogger.success('[SessionManager] Shared preferences cleared');
    } catch (e) {
      AppLogger.error('[SessionManager] Error clearing shared preferences: $e');
    }
  }

  /// Clear Firebase user data (set offline status, clear push token)
  Future<void> _clearFirebaseData() async {
    try {
      AppLogger.lifecycle('[SessionManager] Clearing Firebase data...');
      
      final secureStorage = SecureStorageService();
      final userId = await secureStorage.getUserId();
      
      if (userId != null && userId.isNotEmpty && userId != '0') {
        await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(userId)
            .update({
          'is_online': false,
          'is_mobile_online': false,
          'is_web_online': false,
          'push_token': '',
          'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        });
        AppLogger.success('[SessionManager] Firebase data cleared for user: $userId');
      }
    } catch (e) {
      AppLogger.error('[SessionManager] Error clearing Firebase data: $e');
    }
  }

  /// Clear FCM token
  Future<void> _clearFCMToken() async {
    try {
      AppLogger.lifecycle('[SessionManager] Clearing FCM token...');
      await FirebaseMessaging.instance.deleteToken();
      AppLogger.success('[SessionManager] FCM token cleared');
    } catch (e) {
      AppLogger.error('[SessionManager] Error clearing FCM token: $e');
    }
  }

  /// Clear all GetX controllers that hold user data
  Future<void> _clearGetXControllers() async {
    try {
      AppLogger.lifecycle('[SessionManager] Clearing GetX controllers...');

      // List of controllers to clear
      final controllersToDelete = <Type>[
        ChatViewModel,
        BottomNavController,
        ProfileController,
        ChatListController,
      ];

      for (final controllerType in controllersToDelete) {
        try {
          if (controllerType == ChatViewModel && Get.isRegistered<ChatViewModel>()) {
            Get.delete<ChatViewModel>(force: true);
          } else if (controllerType == BottomNavController && Get.isRegistered<BottomNavController>()) {
            Get.delete<BottomNavController>(force: true);
          } else if (controllerType == ProfileController && Get.isRegistered<ProfileController>()) {
            Get.delete<ProfileController>(force: true);
          } else if (controllerType == ChatListController && Get.isRegistered<ChatListController>()) {
            Get.delete<ChatListController>(force: true);
          }
        } catch (e) {
          AppLogger.error('[SessionManager] Error deleting $controllerType: $e');
        }
      }

      AppLogger.success('[SessionManager] GetX controllers cleared');
    } catch (e) {
      AppLogger.error('[SessionManager] Error clearing GetX controllers: $e');
    }
  }

  /// Clear notification session
  void _clearNotificationSession() {
    try {
      AppLogger.lifecycle('[SessionManager] Clearing notification session...');
      NotificationServices.clearSession();
      AppLogger.success('[SessionManager] Notification session cleared');
    } catch (e) {
      AppLogger.error('[SessionManager] Error clearing notification session: $e');
    }
  }

  /// Quick logout - called from deactivation screen
  Future<void> quickLogout() async {
    await clearAllSessionData();
  }

  /// Check if user session is valid
  Future<bool> isSessionValid() async {
    try {
      final secureStorage = SecureStorageService();
      final isLoggedIn = await secureStorage.isUserLoggedIn();
      final userId = await secureStorage.getUserId();
      
      return isLoggedIn && userId != null && userId.isNotEmpty && userId != '0';
    } catch (e) {
      AppLogger.error('[SessionManager] Error checking session validity: $e');
      return false;
    }
  }
}
