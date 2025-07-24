// bottom_nav_view.dart - Fixed for proper app lifecycle management

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/export.dart';
import '../../core/services/firebase_service/export.dart';
import '../../utils/exports.dart';

import '../../viewmodels/chat_viewmodel.dart';
import '../chat/export.dart';
import '../home/home_view.dart';
import '../profile/export.dart';

class BottomNavView extends StatefulWidget {
  final int index;

  const BottomNavView({
    super.key,
    this.index = 0,
  });

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView>
    with WidgetsBindingObserver {
  int selectedTab = 0;

  final notificationService = NotificationServices();

  final List pages = [
    const HomeView(),
    const ChatUserListingView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    updateTab();
    WidgetsBinding.instance.addObserver(this);

    // FIXED: Proper initialization sequence
    _initializeApp();

  }

  Future<void> _initializeApp() async {
    debugPrint('🚀 Initializing app...');

    try {
      // 1. Initialize Firebase user first
      await _initializeFirebaseUser();

      // 2. Set app state to foreground
      FirebaseService.setAppState(isInForeground: false, isInChat: false);

      // 3. Update online status
      await _updateStatus(true);

      debugPrint('✅ App initialization completed');
    } catch (e) {
      debugPrint('❌ Error initializing app: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('🔚 BottomNav disposing...');

    // FIXED: Proper cleanup
    FirebaseService.setAppState(isInForeground: false, isInChat: false);
    _updateStatus(false);

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App lifecycle changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
      // FIXED: App is visible and responding
        FirebaseService.setAppState(isInForeground: true, isInChat: true);
        _updateStatus(true);
        debugPrint('📱 App resumed - marking online');
        break;

      case AppLifecycleState.paused:
      // FIXED: App is not visible but still running (screen locked/background)
        FirebaseService.setAppState(isInForeground: false);
        _updateStatus(false);
        debugPrint('⏸️ App paused - marking offline');
        break;

      case AppLifecycleState.inactive:
      // FIXED: App is transitioning (like when receiving call)
        FirebaseService.setAppState(isInForeground: false);
        debugPrint('💤 App inactive');
        break;

      case AppLifecycleState.detached:
      // App is about to be terminated
        FirebaseService.setAppState(isInForeground: false, isInChat: false);
        _updateStatus(false);
        debugPrint('🔌 App detached - marking offline');
        break;

      case AppLifecycleState.hidden:
      // App is hidden
        FirebaseService.setAppState(isInForeground: false);
        debugPrint('👻 App hidden');
        break;
    }
  }

  // FIXED: Better status update with error handling
  Future<void> _updateStatus(bool isOnline) async {
    try {
      await FirebaseService.updateActiveStatus(isOnline);
      debugPrint('✅ Status updated: ${isOnline ? "Online" : "Offline"}');
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      // Retry once after a delay
      await Future.delayed(const Duration(seconds: 2));
      try {
        await FirebaseService.updateActiveStatus(isOnline);
        debugPrint('✅ Status updated on retry');
      } catch (retryError) {
        debugPrint('❌ Retry failed: $retryError');
      }
    }
  }

  // FIXED: Proper Firebase initialization
  Future<void> _initializeFirebaseUser() async {
    debugPrint('🔄 Initializing Firebase user...');

    try {
      // Initialize Firebase self info
      await FirebaseService.getSelfInfo();

      // Ensure ChatViewModel is available
      if (!Get.isRegistered<ChatViewModel>()) {
        Get.put(ChatViewModel());
      }

      final chatController = Get.find<ChatViewModel>();
      await chatController.initSelf();

      debugPrint('✅ Firebase user initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase user: $e');

      // Retry after delay
      await Future.delayed(const Duration(seconds: 2));
      try {
        await FirebaseService.getSelfInfo();
        debugPrint('✅ Firebase user initialized on retry');
      } catch (retryError) {
        debugPrint('❌ Firebase initialization retry failed: $retryError');
      }
    }
  }

  void updateTab() {
    setState(() {
      selectedTab = widget.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize notifications
    notificationInit(context: context);

    return WillPopScope(
      onWillPop: () async {
        // FIXED: Proper exit handling
        bool? shouldExit = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    // Clean up before exit
                    FirebaseService.setAppState(isInForeground: false, isInChat: false);
                    await _updateStatus(false);
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: pages[selectedTab],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.whiteColor,
          currentIndex: selectedTab,
          onTap: (index) => changeTab(index),
          selectedItemColor: AppColors.secondaryColor,
          unselectedItemColor: AppColors.greyColor.withValues(alpha: 0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(
            color: AppColors.secondaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            color: AppColors.secondaryColor,
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
          items: [
            BottomNavigationBarItem(
              icon: ImageHelper(
                image: AppAssets.icHome,
                imageType: ImageType.asset,
                height: 24,
                width: 24,
              ),
              activeIcon: ImageHelper(
                image: AppAssets.icHome,
                imageType: ImageType.asset,
                color: AppColors.secondaryColor,
                height: 24,
                width: 24,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: ImageHelper(
                image: AppAssets.icChat,
                imageType: ImageType.asset,
                height: 24,
                width: 24,
              ),
              activeIcon: ImageHelper(
                image: AppAssets.icChat,
                imageType: ImageType.asset,
                color: AppColors.secondaryColor,
                height: 24,
                width: 24,
              ),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: ImageHelper(
                image: AppAssets.icProfile,
                imageType: ImageType.asset,
                height: 24,
                width: 24,
              ),
              activeIcon: ImageHelper(
                image: AppAssets.icProfile,
                imageType: ImageType.asset,
                color: AppColors.secondaryColor,
                height: 24,
                width: 24,
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  void changeTab(int index) {
    setState(() {
      selectedTab = index;
    });

    // ADDED: Track which tab user is on
    if (index == 1) { // Chat tab
      FirebaseService.setAppState(isInChat: false); // Not inside specific chat, just chat list
    } else {
      FirebaseService.setAppState(isInChat: false);
    }
  }

  void notificationInit({required BuildContext context}) {
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