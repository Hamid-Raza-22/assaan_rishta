// Optimized bottom_nav_viewmodel.dart
import 'dart:async';
import 'dart:io';
import 'package:assaan_rishta/app/views/account_type/account_type_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/models/chat_model/message.dart';
import '../core/services/env_config_service.dart';
import '../core/services/firebase_service/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
import '../views/chat/chat_user_listing_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/filter/export.dart';
import '../views/vendor/export.dart';
import '../views/home/home_view.dart';
import '../views/profile/export.dart';
import 'chat_list_viewmodel.dart';
import 'chat_viewmodel.dart';

class BottomNavController extends GetxController with WidgetsBindingObserver {
  final RxInt selectedTab = 0.obs;
  final notificationService = NotificationServices();
  late final UserManagementUseCase useCase;
  bool isNotificationInitialized = false;
  bool _isInitialized = false;

  // Cache login status for sync getters
  final RxBool isLoggedIn = false.obs;
  final RxInt userRoleId = 0.obs;

  // Debouncing for status updates
  Timer? _statusUpdateTimer;
  bool _lastKnownStatus = true;

  // Cached pages to avoid recreation
  late final List<Widget> pages;
  late final List<Widget> adminPages; // Pages for admin users (roleId 3)
  late final List<Widget> guestPages; // Pages for non-logged in users

  @override
  void onInit() {
    super.onInit();
    useCase = Get.find<UserManagementUseCase>(); // Initialize useCase
    _initializePages();
    _loadLoginStatus();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    manualVersionCheck();
  }

  // Load login status from secure storage
  void _loadLoginStatus() async {
    isLoggedIn.value = useCase.getUserLoggedInStatus();
    // Load user role ID
    final roleId = await useCase.getUserRoleId();
    userRoleId.value = roleId;
  }

  /// Call this after login to refresh controller state and reset tab index
  void refreshAfterLogin() async {
    debugPrint('🔄 Refreshing BottomNavController after login');
    
    // Reload login status
    isLoggedIn.value = useCase.getUserLoggedInStatus();
    
    // Load user role ID
    final roleId = await useCase.getUserRoleId();
    userRoleId.value = roleId;
    
    // Reset to home tab (index 0) to avoid tab mismatch
    // Guest has 4 tabs, logged-in has 5 tabs - indices shift after login
    selectedTab.value = 0;
    
    // Re-initialize Firebase user if logged in
    if (isLoggedIn.value) {
      _initializeFirebaseUser();
      FirebaseService.setAppState(isInForeground: true, isInChat: false);
    }
    
    debugPrint('✅ BottomNavController refreshed - isLoggedIn: ${isLoggedIn.value}, roleId: ${userRoleId.value}, tab: ${selectedTab.value}');
  }

  void _initializePages() {
    pages = [
      const HomeView(),
      const VendorView(),
      const ChatUserListingView(),
      const FilterView(),
      const ProfileView(),
    ];
    // Admin pages - Dashboard instead of Profile
    adminPages = [
      const HomeView(),
      const VendorView(),
      const ChatUserListingView(),
      const FilterView(),
      const DashboardView(),
    ];
    // Limited pages for guest users (only Home, Vendor, Filter, Account Type)
    guestPages = [
      const HomeView(),
      const VendorView(),
      const FilterView(),
      const AccountTypeView()
    ];
  }

  // Get current pages based on login status and role
  List<Widget> get currentPages {
    if (!isLoggedIn.value) return guestPages;
    return userRoleId.value == 3 ? adminPages : pages;
  }

  // Get current page count based on login status
  int get pageCount => currentPages.length;

  @override
  void onClose() {
    debugPrint('🔚 BottomNav disposing...');
    _statusUpdateTimer?.cancel();
    cleanUpBeforeExit();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> cleanUpBeforeExit() async {
    if (!_isInitialized) return;

    FirebaseService.setAppState(isInForeground: false, isInChat: false);
    await _updateStatusImmediate(false);
  }

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    // Ensure index is within valid range
    if (index >= pageCount) return;

    selectedTab.value = index;

    _performVersionCheck();
    // Only set chat state if user is logged in and on chat tab
    if (isLoggedIn.value) {
      FirebaseService.setAppState(isInChat: index == 2); // Chat is at index 2 for logged in users
    }
  }

  void _performVersionCheck() {
    if (Get.context != null) {
      debugPrint('🔍 Performing version check...');
      versionCheck(Get.context!);
    }
  }

  // Method to manually trigger version check (can be called from anywhere)
  void manualVersionCheck() {
    _performVersionCheck();
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return;

    debugPrint('🚀 Initializing app...');

    try {
      // Only initialize Firebase if user is logged in
      bool loginStatus = await useCase.getUserLoggedInStatus();
      isLoggedIn.value = loginStatus; // Update cached value

      if (loginStatus) {
        await _initializeFirebaseUser();
        FirebaseService.setAppState(isInForeground: true, isInChat: false);
        await _updateStatusImmediate(true);
      }

      _isInitialized = true;
      debugPrint('✅ App initialization completed');
    } catch (e) {
      debugPrint('❌ Error initializing app: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;
    // Only handle lifecycle for logged in users
    if (!isLoggedIn.value) return;
    debugPrint('📱 App lifecycle changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        FirebaseService.setAppState(isInForeground: true, isInChat: selectedTab.value == 2);
        _updateStatusDebounced(true);
        _handleAppResume();
        break;
      case AppLifecycleState.paused:
        // _handleAppPause();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        FirebaseService.setAppState(isInForeground: false);
        _updateStatusDebounced(false);
        break;
      case AppLifecycleState.detached:
        FirebaseService.setAppState(isInForeground: false, isInChat: false);
        _updateStatusImmediate(false);
        break;
    }
  }
  void _handleAppResume() async {
    debugPrint('📱 App resumed - processing pending deliveries');

    try {
      FirebaseService.setAppState(isInForeground: true);

      if (FirebaseService.me != null) {
        await FirebaseService.updateActiveStatus(true);
      }

      // Process ALL pending message deliveries
      await _processAllPendingDeliveries();

      // If in chat, also mark messages as read
      if (Get.isRegistered<ChatViewModel>()) {
        final chatViewModel = Get.find<ChatViewModel>();
        if (chatViewModel.selectedUser.value != null) {
          await chatViewModel.markIncomingMessagesAsDelivered();
        }
      }

      if (Get.isRegistered<ChatListController>()) {
        final controller = Get.find<ChatListController>();
        controller.resetAllStates();
      }
    } catch (e) {
      debugPrint('❌ Error handling app resume: $e');
    }
  }
  Future<void> _processAllPendingDeliveries() async {
    try {
      final currentUserId = (await useCase.getUserId()).toString();

      // Get all conversations
      final myUsersSnapshot = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(currentUserId)
          .collection('my_users')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      int updateCount = 0;

      for (var userDoc in myUsersSnapshot.docs) {
        final otherUserId = userDoc.id;
        final conversationId = _getConversationId(currentUserId, otherUserId);

        // Get ALL undelivered messages for this conversation
        final undeliveredMessages = await FirebaseFirestore.instance
            .collection(EnvConfig.firebaseChatsCollection)
            .doc(conversationId)
            .collection('messages')
            .where('toId', isEqualTo: currentUserId)
            .where('fromId', isEqualTo: otherUserId)
            .get();

        final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

        for (var doc in undeliveredMessages.docs) {
          final data = doc.data();
          // Check if not already delivered
          if (data['delivered'] == null || data['delivered'].toString().isEmpty) {
            batch.update(doc.reference, {
              'delivered': deliveredTime,
              'status': MessageStatus.delivered.name,
              'deliveryPending': false,
            });
            updateCount++;
          }
        }
      }

      if (updateCount > 0) {
        await batch.commit();
        debugPrint('✅ Marked $updateCount messages as delivered on app resume');
      }
    } catch (e) {
      debugPrint('❌ Error processing pending deliveries: $e');
    }
  }

  String _getConversationId(String userId1, String userId2) {
    return userId1.compareTo(userId2) <= 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  void _updateStatusDebounced(bool isOnline) {
    if (_lastKnownStatus == isOnline) return;

    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = Timer(const Duration(milliseconds: 500), () {
      _updateStatusImmediate(isOnline);
    });
  }

  Future<void> _updateStatusImmediate(bool isOnline) async {
    if (_lastKnownStatus == isOnline) return;

    try {
      await FirebaseService.updateActiveStatus(isOnline);
      _lastKnownStatus = isOnline;
      debugPrint('✅ Status updated: ${isOnline ? "Online" : "Offline"}');
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      // Retry once after delay
      Future.delayed(const Duration(seconds: 2), () {
        FirebaseService.updateActiveStatus(isOnline).catchError((e) {
          debugPrint('❌ Retry failed: $e');
        });
      });
    }
  }

  Future<void> _initializeFirebaseUser() async {
    debugPrint('🔄 Initializing Firebase user...');

    try {
      await FirebaseService.getSelfInfo();

      if (!Get.isRegistered<ChatViewModel>()) {
        Get.put(ChatViewModel());
      }

      final chatController = Get.find<ChatViewModel>();
      await chatController.initSelf();

      debugPrint('✅ Firebase user initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase user: $e');
      rethrow;
    }
  }

  void updateTab(int index) {
    if (index >= pageCount) return;
    if (selectedTab.value != index) {
      selectedTab.value = index;
    }
  }

  void notificationInit({required BuildContext context}) {
    if (isNotificationInitialized) return;

    notificationService.requestNotificationPermission();
    notificationService.forGroundMessage();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.isTokenRefresh();

    if (Platform.isAndroid) {
      notificationService.getDeviceToken().then((fcmToken) {
        _updateFcmToken(fcmToken);
        debugPrint('📱 FCM Token: $fcmToken');
      });
    }

    isNotificationInitialized = true;
  }

  Future<void> _updateFcmToken(String fcmToken) async {
    try {
      await FirebaseService.updateFcmToken(fcmToken: fcmToken);
      debugPrint('✅ FCM Token updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
    }
  }
}