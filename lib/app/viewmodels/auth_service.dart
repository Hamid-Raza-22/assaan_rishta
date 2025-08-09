// auth_service.dart - FIXED VERSION WITH NOTIFICATION HANDLING
import 'package:assaan_rishta/app/viewmodels/chat_list_viewmodel.dart';
import 'package:assaan_rishta/app/viewmodels/profile_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/routes/app_routes.dart';
import '../core/services/firebase_service/export.dart';
import '../core/services/storage_services/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
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
      debugPrint('🔐 Checking authentication status...');
      final prefs = await SharedPreferences.getInstance();

      final isLoggedIn = prefs.getBool(StorageKeys.isUserLoggedIn) ?? false;
      final userId = prefs.getInt(StorageKeys.userId);
      final userEmail = prefs.getString(StorageKeys.userEmail);
      final userName = prefs.getString(StorageKeys.userName);
      final userImage = prefs.getString(StorageKeys.userPic);

      if (isLoggedIn && userId != null && userId > 0) {
        _userId = userId;
        _userEmail = userEmail;
        _userName = userName;
        _userImage = userImage;

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

        debugPrint('✅ User authenticated: $userName (ID: $userId)');

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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.isUserLoggedIn, true);
      await prefs.setInt(StorageKeys.userId, userId);
      await prefs.setString(StorageKeys.userEmail, email);
      await prefs.setString(StorageKeys.userName, name);
      await prefs.setString(StorageKeys.userPic, image);

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
      debugPrint('🚪 Starting logout process...');
      NotificationServices.clearSession();
      // 1. Update Firebase status
      if (_userId != null) {
        await FirebaseService.updateActiveStatus(false);
        await FirebaseService.insideChatStatus(false);
      }

      // 2. Remove FCM token from Firestore
      await _removeFCMToken();

      // 3. Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 4. Reset local variables
      _userId = null;
      _userEmail = null;
      _userName = null;
      _userImage = null;

      // 5. Update observable states
      isUserLoggedIn.value = false;
      currentUser.value = null;
      _clearGetXInstances();
      // 6. Clear chat controller if exists
      if (Get.isRegistered<ChatViewModel>()) {
        final chatController = Get.find<ChatViewModel>();
        chatController.dispose();
      }

      debugPrint('✅ Logout completed successfully');

      // 7. Navigate to login
      Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);


    } catch (e) {
      NotificationServices.clearSession();
      debugPrint('💥 Error during logout: $e');
      // Even if there's an error, clear local data and navigate
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      isUserLoggedIn.value = false;
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);
    }
  }
// Alternative method if you want to clear ALL GetX instances (use with caution)
  void _clearGetXInstances() {
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

      debugPrint('🧹 All GetX instances cleared');
    } catch (e) {
      debugPrint('⚠️ Error clearing GetX instances: $e');
    }
  }
  // Update FCM token in Firestore
  Future<void> _updateFCMToken() async {
    try {
      if (_userId == null || _userId! <= 0) return;

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      debugPrint('📱 Updating FCM token for user: $_userId');

      // Update token in Firestore
      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_userId.toString())
          .update({
        'push_token': fcmToken,
        'last_token_update': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ FCM token updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
    }
  }

  // Remove FCM token from Firestore
  Future<void> _removeFCMToken() async {
    try {
      if (_userId == null || _userId! <= 0) return;

      debugPrint('🔕 Removing FCM token for user: $_userId');

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

      debugPrint('✅ FCM token removed successfully');
    } catch (e) {
      debugPrint('❌ Error removing FCM token: $e');
    }
  }

  // Check if user needs to login
  Future<bool> checkIfUserLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(StorageKeys.isUserLoggedIn) ?? false;
      final userId = prefs.getInt(StorageKeys.userId) ?? 0;

      return isLoggedIn && userId > 0;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
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