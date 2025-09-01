import 'dart:async';
import 'dart:io';

import 'package:assaan_rishta/app/core/bindings/app_bindings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/core/di/export.dart';
import 'app/core/routes/app_pages.dart';
import 'app/core/routes/app_routes.dart';
import 'app/core/services/deep_link_handler.dart';
import 'app/core/services/firebase_service/delivery_confirmation_service.dart';
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

//@pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('🔥 Background message received: ${message.data}');
//
//   // If it's a chat message, ensure sender is added to receiver's list
//   if (message.data['type'] == 'chat') {
//     final senderId = message.data['senderId'];
//     final receiverId = message.data['receiverId'];
//     final messageTimestamp = message.data['timestamp'] as String?;
//
//     if (senderId != null &&
//         senderId.isNotEmpty &&
//         messageTimestamp != null &&
//         receiverId != null &&
//         receiverId.isNotEmpty) {
//       try {
//         debugPrint('📱 Background: Adding $senderId to $receiverId\'s chat list');
//
//         // FIXED: Use the actual message timestamp from notification
//         await confirmBackgroundMessageDelivery(
//           isBackground: true, // Indicate this is a background call
//           senderId: senderId,
//           receiverId: receiverId,
//           messageTimestamp: messageTimestamp, // Use actual message timestamp
//         );
//         debugPrint('✅ Background: Message delivery confirmed for $messageTimestamp');
//
//         // Add sender to receiver's my_users collection
//         await FirebaseFirestore.instance
//             .collection('Hamid_users')
//             .doc(receiverId)
//             .collection('my_users')
//             .doc(senderId)
//             .set({
//           'last_message_time': messageTimestamp, // Use actual timestamp
//           'added_at': DateTime.now().millisecondsSinceEpoch.toString(),
//         }, SetOptions(merge: true));
//
//         debugPrint(
//             '✅ Background: Sender added to chat list successfully.');
//       } catch (e) {
//         debugPrint('❌ Background: Error processing message: $e');
//       }
//     }
//   }
// }


// In main.dart - Improved background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('🔥 Background message received: ${message.data}');

  if (message.data['type'] == 'chat') {
    final senderId = message.data['senderId'];
    final receiverId = message.data['receiverId'];
    final messageTimestamp = message.data['timestamp'] as String?;

    if (senderId != null && receiverId != null && messageTimestamp != null) {
      // Try multiple approaches to ensure delivery confirmation
      bool deliveryConfirmed = false;

      // Approach 1: Direct Firestore update with retry
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          deliveryConfirmed = await _confirmDeliveryDirectly(
            senderId: senderId,
            receiverId: receiverId,
            messageTimestamp: messageTimestamp,
          );

          if (deliveryConfirmed) {
            debugPrint('✅ Delivery confirmed on attempt ${attempt + 1}');
            break;
          }
        } catch (e) {
          debugPrint('⚠️ Attempt ${attempt + 1} failed: $e');
          if (attempt < 2) {
            await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          }
        }
      }

      // Approach 2: If direct update failed, try batch operation
      if (!deliveryConfirmed) {
        try {
          deliveryConfirmed = await _confirmDeliveryWithBatch(
            senderId: senderId,
            receiverId: receiverId,
            messageTimestamp: messageTimestamp,
          );
        } catch (e) {
          debugPrint('❌ Batch operation failed: $e');
        }
      }

      // Approach 3: Cloud Function as last resort
      if (!deliveryConfirmed) {
        try {
          final result = await DeliveryConfirmationService.confirmDeliveryViaCloudFunction(
            senderId: senderId,
            receiverId: receiverId,
            messageTimestamp: messageTimestamp,
          );
          deliveryConfirmed = result;
        } catch (e) {
          debugPrint('❌ Cloud function failed: $e');
        }
      }

      // Always add sender to receiver's chat list
      try {
        await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(receiverId)
            .collection('my_users')
            .doc(senderId)
            .set({
          'last_message_time': messageTimestamp,
          'added_at': DateTime.now().millisecondsSinceEpoch.toString(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Failed to add to chat list: $e');
      }
    }
  }
}

// Helper function for direct Firestore update
Future<bool> _confirmDeliveryDirectly({
  required String senderId,
  required String receiverId,
  required String messageTimestamp,
}) async {
  try {
    final conversationId = getConversationId(senderId, receiverId);
    final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

    final messageRef = FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .collection('messages')
        .doc(messageTimestamp);

    // First check if message exists
    final messageDoc = await messageRef.get();

    if (!messageDoc.exists) {
      debugPrint('⚠️ Message document not found');
      return false;
    }

    final data = messageDoc.data()!;

    // Check if already delivered
    if (data['delivered'] != null && data['delivered'].toString().isNotEmpty) {
      debugPrint('ℹ️ Message already delivered');
      return true;
    }

    // Update delivery status
    await messageRef.update({
      'delivered': deliveredTime,
      'status': 'delivered',
      'deliveryPending': false,
    });

    return true;
  } catch (e) {
    debugPrint('❌ Direct update error: $e');
    return false;
  }
}

// Helper function for batch operation
Future<bool> _confirmDeliveryWithBatch({
  required String senderId,
  required String receiverId,
  required String messageTimestamp,
}) async {
  try {
    final conversationId = getConversationId(senderId, receiverId);
    final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

    final batch = FirebaseFirestore.instance.batch();

    final messageRef = FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .collection('messages')
        .doc(messageTimestamp);

    batch.update(messageRef, {
      'delivered': deliveredTime,
      'status': 'delivered',
      'deliveryPending': false,
    });

    await batch.commit();
    return true;
  } catch (e) {
    debugPrint('❌ Batch update error: $e');
    return false;
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