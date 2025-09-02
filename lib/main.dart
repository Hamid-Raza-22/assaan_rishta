import 'dart:async';
import 'dart:io';

import 'package:assaan_rishta/app/core/bindings/app_bindings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/di/export.dart';
import 'app/core/routes/app_pages.dart';
import 'app/core/routes/app_routes.dart';
import 'app/core/services/deep_link_handler.dart';
import 'app/core/services/firebase_service/delivery_confirmation_service.dart';
import 'app/core/services/firebase_service/export.dart';
import 'app/data/repositories/chat_repository.dart';
import 'app/domain/export.dart';
import 'app/fast_pay/app/app.locator.dart';
import 'app/utils/app_colors.dart';
import 'app/viewmodels/chat_list_viewmodel.dart';
import 'app/viewmodels/chat_viewmodel.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(const AsanRishtaApp());
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

// FIXED: Main App with proper notification initialization
class AsanRishtaApp extends StatefulWidget {
  const AsanRishtaApp({super.key});

  @override
  State<AsanRishtaApp> createState() => _AsanRishtaAppState();
}

class _AsanRishtaAppState extends State<AsanRishtaApp> with WidgetsBindingObserver {
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize notifications after first frame when context is available
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _initializeNotifications();
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkHandler.dispose();
    super.dispose();
  }
// FIXED: Proper app lifecycle handling for message delivery
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
      // App is transitioning or hidden
        break;
    }
  }

  void _handleAppResume() async {
    debugPrint('📱 App resumed from background');

    try {
      // Update Firebase app state
      FirebaseService.setAppState(isInForeground: true);

      // Update user online status
      if (FirebaseService.me != null) {
        await FirebaseService.updateActiveStatus(true);
      }

      // If we're in a chat, mark undelivered messages
      if (Get.isRegistered<ChatViewModel>()) {
        final chatViewModel = Get.find<ChatViewModel>();
        if (chatViewModel.selectedUser.value != null) {
          final selectedUserId = chatViewModel.selectedUser.value!.id;

          // Mark any undelivered messages as delivered
          final chatRepository = ChatRepository();
          await chatRepository.markMessagesAsDelivered(selectedUserId);

          debugPrint('✅ Marked undelivered messages as delivered for: $selectedUserId');
        }
      }

      // Reset any stuck navigation states
      if (Get.isRegistered<ChatListController>()) {
        final controller = Get.find<ChatListController>();
        controller.resetAllStates();
      }

    } catch (e) {
      debugPrint('❌ Error handling app resume: $e');
    }
  }
 void _handleAppInActive() async {
    debugPrint('📱 App resumed from background');

    try {
      // Update Firebase app state
      FirebaseService.setAppState(isInForeground: false);

      // Update user online status
      if (FirebaseService.me != null) {
        await FirebaseService.updateActiveStatus(false);
      }

      // If we're in a chat, mark undelivered messages
      if (Get.isRegistered<ChatViewModel>()) {
        final chatViewModel = Get.find<ChatViewModel>();
        if (chatViewModel.selectedUser.value != null) {
          final selectedUserId = chatViewModel.selectedUser.value!.id;

          // Mark any undelivered messages as delivered
          final chatRepository = ChatRepository();
          await chatRepository.markMessagesAsDelivered(selectedUserId);

          debugPrint('✅ Marked undelivered messages as delivered for: $selectedUserId');
        }
      }

      // Reset any stuck navigation states
      if (Get.isRegistered<ChatListController>()) {
        final controller = Get.find<ChatListController>();
        controller.resetAllStates();
      }

    } catch (e) {
      debugPrint('❌ Error handling app resume: $e');
    }
  }

  void _handleAppPause() {
    debugPrint('📱 App went to background');

    try {
      // Update Firebase app state
      FirebaseService.setAppState(isInForeground: false);

      // Update user status to offline after a delay
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
      // navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialBinding: AppBindings(),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
     // navigatorKey: StackedService.navigatorKey,
      //onGenerateRoute: StackedRouter().onGenerateRoute,
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
