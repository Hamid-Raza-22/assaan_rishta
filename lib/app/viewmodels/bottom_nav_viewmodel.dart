// Optimized bottom_nav_viewmodel.dart
import 'dart:async';
import 'dart:io';
import 'package:assaan_rishta/app/views/account_type/account_type_view.dart';
import 'package:assaan_rishta/app/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/firebase_service/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
import '../views/chat/chat_user_listing_view.dart';
import '../views/filter/export.dart';
import '../views/vendor/export.dart';
import '../views/home/home_view.dart';
import '../views/profile/export.dart';
import 'chat_viewmodel.dart';

class BottomNavController extends GetxController with WidgetsBindingObserver {
  final RxInt selectedTab = 0.obs;
  final notificationService = NotificationServices();
  late final UserManagementUseCase useCase;
  bool isNotificationInitialized = false;
  bool _isInitialized = false;

  // Debouncing for status updates
  Timer? _statusUpdateTimer;
  bool _lastKnownStatus = true;

  // Cached pages to avoid recreation
  late final List<Widget> pages;
  late final List<Widget> guestPages; // Pages for non-logged in users

  @override
  void onInit() {
    super.onInit();
    useCase = Get.find<UserManagementUseCase>(); // Initialize useCase
    _initializePages();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    manualVersionCheck();
  }

  void _initializePages() {
    pages = [
      const HomeView(),
      const VendorView(),
      const ChatUserListingView(),
      const FilterView(),
      const ProfileView(),
    ];
    // Limited pages for guest users (only Home, Vendor, Filter, Account Type)
    guestPages = [
      const HomeView(),
      const VendorView(),
      const FilterView(),
      const AccountTypeView()
    ];
  }

  // Get current pages based on login status
  List<Widget> get currentPages {
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    return isLoggedIn ? pages : guestPages;
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
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();

    selectedTab.value = index;

    _performVersionCheck();
    // Only set chat state if user is logged in and on chat tab
    if (isLoggedIn) {
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
      bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();

      if (isLoggedIn) {
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
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    if (!isLoggedIn) return;
    debugPrint('📱 App lifecycle changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        FirebaseService.setAppState(isInForeground: true, isInChat: selectedTab.value == 2);
        _updateStatusDebounced(true);
        break;
      case AppLifecycleState.paused:
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