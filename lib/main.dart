
import 'dart:async';
import 'dart:io';

import 'package:assaan_rishta/app/core/bindings/app_bindings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:get/get.dart';

import 'app/config/firebase_options.dart';
import 'app/core/di/export.dart';
import 'app/core/routes/app_pages.dart';
import 'app/core/routes/app_routes.dart';
import 'app/core/services/deep_link_handler.dart';
import 'app/core/services/env_config_service.dart';
import 'app/core/services/secure_storage_service.dart';

import 'app/core/services/firebase_service/delivery_confirmation_service.dart';
import 'app/core/services/firebase_service/export.dart';
import 'app/data/repositories/chat_repository.dart';
import 'app/domain/export.dart';
import 'app/fast_pay/app/app.locator.dart';
import 'app/utils/app_colors.dart';
import 'app/viewmodels/chat_list_viewmodel.dart';
import 'app/viewmodels/chat_viewmodel.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isFirstInstall() async {
  final prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_install') ?? true;

  // Don't set the flag here - set it after clearing data
  return isFirstTime;
}

Future<void> main() async {
  if (kReleaseMode || kProfileMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Configuration
  try {
    await EnvConfig.init();
    if (!EnvConfig.validate()) {
      throw Exception('❌ Environment variables validation failed. Check .env file.');
    }
    debugPrint('✅ Environment configuration loaded successfully');
  } catch (e) {
    debugPrint('❌ Failed to load environment configuration: $e');
    // You might want to show an error screen here
  }

  // Initialize Secure Storage
  try {
    await SecureStorageService().init();
    debugPrint('✅ Secure storage initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize secure storage: $e');
  }

  bool firstTime = await isFirstInstall();

  if (firstTime) {
    // Clear all data on first install
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Clear secure storage as well
    await SecureStorageService().clearAll();
    // NOW set the flag after clearing everything else
    await prefs.setBool('first_install', false);
  }

  HttpOverrides.global = MyHttpOverrides();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupLocator();

  ///Initializing UseCase and Repo Dependencies <- Start ->
  final RepoDependencies repoDependencies = RepoDependencies();
  await repoDependencies.init().whenComplete(() {});
  await repoDependencies.initializeRepoDependencies();
  await initializeModelUseCasesDependencies();

  ///Initializing UseCase and Repo Dependencies <- End ->

  // Setup background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // DON'T initialize notifications here - wait for context in app
  // Initialize deep links
  await DeepLinkHandler.initDeepLinks();
  // Decide initial route based on onboarding completion
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final String initialRoute = (firstTime || !hasSeenOnboarding)
      ? AppRoutes.ONBOARDING
      : AppRoutes.SPLASH;

  runApp(AsanRishtaApp(initialRoute: initialRoute));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('🔥 Background message received');
  debugPrint('📋 Message data: ${message.data}');

  if (message.data['type'] == 'chat') {
    // Extract and validate data
    final senderId = message.data['senderId']?.toString().trim();
    final receiverId = message.data['receiverId']?.toString().trim();
    final messageTimestamp = message.data['timestamp']?.toString().trim();

    // Log received values for debugging
    debugPrint('📍 Processing chat message:');
    debugPrint('  From: $senderId');
    debugPrint('  To: $receiverId');
    debugPrint('  Timestamp: $messageTimestamp');

    // Validate all required fields are present and not empty
    if (senderId != null && senderId.isNotEmpty &&
        receiverId != null && receiverId.isNotEmpty &&
        messageTimestamp != null && messageTimestamp.isNotEmpty) {

      bool deliveryConfirmed = false;

      // Step 1: Try direct Firestore update (fastest and most reliable)
      try {
        debugPrint('🔄 Attempting direct Firestore update...');
        deliveryConfirmed = await DeliveryConfirmationService.confirmDeliveryDirectly(
          senderId: senderId,
          receiverId: receiverId,
          messageTimestamp: messageTimestamp,
        );

        if (deliveryConfirmed) {
          debugPrint('✅ Delivery confirmed via direct update');
        }
      } catch (e) {
        debugPrint('⚠️ Direct update failed: $e');
      }

      // Step 2: If direct update failed, try cloud function
      if (!deliveryConfirmed) {
        try {
          debugPrint('☁️ Attempting cloud function...');
          deliveryConfirmed = await DeliveryConfirmationService.confirmDeliveryViaDio(
            senderId: senderId,
            receiverId: receiverId,
            messageTimestamp: messageTimestamp,
          );

          if (deliveryConfirmed) {
            debugPrint('✅ Delivery confirmed via cloud function');
          }
        } catch (e) {
          debugPrint('⚠️ Cloud function failed: $e');
        }
      }

      // Step 3: Always update the chat list (this ensures the chat appears even if message not found)
      try {
        await DeliveryConfirmationService.addToChatList(
          senderId: senderId,
          receiverId: receiverId,
          messageTimestamp: messageTimestamp,
        );
        debugPrint('✅ Chat list updated successfully');
      } catch (e) {
        debugPrint('❌ Failed to update chat list: $e');
      }

      // Log final status
      if (deliveryConfirmed) {
        debugPrint('🎯 Message delivery fully confirmed');
      } else {
        debugPrint('⚠️ Message delivery could not be confirmed, but chat list was updated');
      }

    } else {
      // Log exactly what's missing
      debugPrint('❌ Missing required fields:');
      if (senderId == null || senderId.isEmpty) {
        debugPrint('  - senderId is ${senderId == null ? "null" : "empty"}');
      }
      if (receiverId == null || receiverId.isEmpty) {
        debugPrint('  - receiverId is ${receiverId == null ? "null" : "empty"}');
      }
      if (messageTimestamp == null || messageTimestamp.isEmpty) {
        debugPrint('  - messageTimestamp is ${messageTimestamp == null ? "null" : "empty"}');
      }
    }
  } else {
    debugPrint('📨 Non-chat notification received: ${message.data['type']}');
  }
}

class AsanRishtaApp extends StatefulWidget {
  final String initialRoute;

  const AsanRishtaApp({super.key, required this.initialRoute});

  @override
  State<AsanRishtaApp> createState() => _AsanRishtaAppState();
}

class _AsanRishtaAppState extends State<AsanRishtaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkHandler.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('🔄 App lifecycle state: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResume();
        break;
      case AppLifecycleState.paused:
        _handleAppPause();
        break;
      case AppLifecycleState.inactive:
        _handleAppInActive();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleAppResume() async {
    debugPrint('📱 App resumed from background');

    try {
      FirebaseService.setAppState(isInForeground: true);

      if (FirebaseService.me != null) {
        await FirebaseService.updateActiveStatus(true);
      }

      if (Get.isRegistered<ChatViewModel>()) {
        final chatViewModel = Get.find<ChatViewModel>();
        if (chatViewModel.selectedUser.value != null) {
          final selectedUserId = chatViewModel.selectedUser.value!.id;
          final chatRepository = ChatRepository();
          await chatRepository.markMessagesAsDelivered(selectedUserId);
          debugPrint('✅ Marked undelivered messages as delivered for: $selectedUserId');
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

  void _handleAppInActive() async {
    debugPrint('📱 App is inactive');

    try {
      FirebaseService.setAppState(isInForeground: false);

      if (FirebaseService.me != null) {
        await FirebaseService.updateActiveStatus(false);
      }
    } catch (e) {
      debugPrint('❌ Error handling app inactive state: $e');
    }
  }

  void _handleAppPause() {
    debugPrint('📱 App went to background');

    try {
      FirebaseService.setAppState(isInForeground: false);

      Timer(const Duration(seconds: 30), () async {
        if (FirebaseService.me != null) {
          await FirebaseService.updateActiveStatus(false);
        }
      });

    } catch (e) {
      debugPrint('❌ Error handling app pause: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Asaan Rishta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialBinding: AppBindings(),
      initialRoute: widget.initialRoute,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
