import 'dart:async';
import 'dart:io';

import 'package:assaan_rishta/app/core/bindings/app_bindings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/core/di/export.dart';
import 'app/core/routes/app_pages.dart';
import 'app/core/routes/app_routes.dart';
import 'app/core/services/deep_link_handler.dart';
import 'app/core/services/firebase_service/export.dart';
import 'app/data/repositories/chat_repository.dart';
import 'app/domain/export.dart';
import 'app/fast_pay/app/app.locator.dart';
import 'app/fast_pay/app/app.router.dart';
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

// main.dart - Fixed background message handler

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔥 Background message received: ${message.data}');

  // If it's a chat message, ensure sender is added to receiver's list
  if (message.data['type'] == 'chat') {
    final senderId = message.data['senderId'];
    final receiverId = message.data['receiverId'];
    final messageTimestamp = message.data['timestamp'] as String?;

    if (senderId != null && senderId.isNotEmpty && messageTimestamp != null && receiverId != null) {
      try {
        debugPrint('📱 Background: Adding $senderId to $receiverId\'s chat list');

        // FIXED: Use the actual message timestamp from notification
        await confirmBackgroundMessageDelivery(
          senderId: senderId,
          receiverId: receiverId,
          messageTimestamp: messageTimestamp, // Use actual message timestamp
        );

        // Add sender to receiver's my_users collection
        await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(receiverId)
            .collection('my_users')
            .doc(senderId)
            .set({
          'last_message_time': messageTimestamp, // Use actual timestamp
          'added_at': DateTime.now().millisecondsSinceEpoch.toString(),
        }, SetOptions(merge: true));

        debugPrint('✅ Background: Sender added to chat list and message marked as delivered');
      } catch (e) {
        debugPrint('❌ Background: Error processing message: $e');
      }
    }
  }
}

// FIXED: Better delivery confirmation
Future<void> confirmBackgroundMessageDelivery({
  required String senderId,
  required String receiverId,
  required String messageTimestamp,
}) async {
  try {
    final conversationId = getConversationId(senderId, receiverId);
    final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

    // Check if message exists and needs delivery confirmation
    final messageDoc = await FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .collection('messages')
        .doc(messageTimestamp)
        .get();

    if (messageDoc.exists) {
      final data = messageDoc.data()!;

      // Only update if not already delivered and message is for this receiver
      if ((data['delivered'] == null || data['delivered'].toString().isEmpty) &&
          data['toId'] == receiverId) {

        await messageDoc.reference.update({
          'delivered': deliveredTime,
          'status': 'delivered',
          'deliveryPending': false,
        });

        debugPrint('✅ Message delivery confirmed in background for timestamp: $messageTimestamp');
      } else {
        debugPrint('ℹ️ Message already delivered or not for this receiver');
      }
    } else {
      debugPrint('⚠️ Message document not found: $messageTimestamp');
    }
  } catch (e) {
    debugPrint('❌ Error confirming background delivery: $e');
  }
}
// Confirm delivery when app receives notification in background

String getConversationId(String userId1, String userId2) {
  if (userId1.compareTo(userId2) <= 0) {
    return '${userId1}_$userId2';
  } else {
    return '${userId2}_$userId1';
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
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   debugPrint('🔄 App lifecycle state: $state');
  //
  //   // Handle app lifecycle for notifications
  //   if (state == AppLifecycleState.resumed) {
  //     // App came to foreground
  //     _handleAppResume();
  //   } else if (state == AppLifecycleState.paused) {
  //     // App went to background
  //     _handleAppPause();
  //   }
  // }

  // void _initializeNotifications() {
  //   try {
  //     // Get context from navigator key or use widget's context
  //     final currentContext = navigatorKey.currentContext ?? context;
  //
  //     if (currentContext != null) {
  //       debugPrint('🔔 Initializing notifications...');
  //       NotificationInitializer.initializeNotifications(currentContext);
  //     } else {
  //       // Retry after a delay if context not available
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         _initializeNotifications();
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Error initializing notifications: $e');
  //   }
  // }

  // void _handleAppResume() {
  //   debugPrint('📱 App resumed from background');
  //
  //   // CRITICAL: Clear any lingering chat state when app resumes
  //   if (Get.isRegistered<ChatViewModel>()) {
  //     final chatViewModel = Get.find<ChatViewModel>();
  //     // Only clear if not currently in a chat view
  //     final currentRoute = Get.currentRoute;
  //     if (!currentRoute.contains('/chatting_view/') &&
  //         !currentRoute.contains('/ChattingView')) {
  //       chatViewModel.forceClearChatState();
  //       debugPrint('🧹 Cleared chat state on app resume');
  //     }
  //   }
  //
  //   // Reset any stuck navigation states
  //   if (Get.isRegistered<ChatListController>()) {
  //     final controller = Get.find<ChatListController>();
  //     controller.resetAllStates();
  //   }
  // }
  //
  // void _handleAppPause() {
  //   debugPrint('📱 App went to background');
  // }

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

// // FIXED: Notification initializer with proper static method
// class NotificationInitializer {
//   static NotificationServices? _notificationService;
//
//   static void initializeNotifications(BuildContext context) {
//     try {
//       // Create notification service instance if not exists
//       _notificationService ??= NotificationServices();
//       final notificationService = _notificationService!;
//
//       // Request permissions
//       notificationService.requestNotificationPermission();
//
//       // Setup Firebase init with context
//       notificationService.firebaseInit(context);
//
//       // Setup interaction handler with context
//       notificationService.setupInteractMessage(context);
//
//       // Get and store device token
//       notificationService.getDeviceToken().then((token) {
//         debugPrint('🔑 Device token received: ${token?.substring(0, 20)}...');
//
//         // Store token if user is logged in
//         if (Get.isRegistered<UserManagementUseCase>()) {
//           final useCase = Get.find<UserManagementUseCase>();
//           final userId = useCase.getUserId();
//           if (userId != null && token != null) {
//             NotificationServices.storeFCMToken(userId.toString());
//           }
//         }
//       });
//
//       // Listen for token refresh
//       notificationService.isTokenRefresh();
//
//       debugPrint('✅ Notifications initialized successfully');
//     } catch (e) {
//       debugPrint('❌ Error in notification initialization: $e');
//     }
//   }
//
//   // Method to reinitialize if needed
//   static void reinitialize(BuildContext context) {
//     debugPrint('🔄 Reinitializing notifications...');
//     _notificationService = null;
//     initializeNotifications(context);
//   }
//
//   // Clean up method
//   static void dispose() {
//     _notificationService = null;
//   }
// }