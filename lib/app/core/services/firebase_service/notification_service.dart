// notification_service.dart - FIXED with user validation for notifications

import 'dart:convert';
import 'dart:io';

import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:assaan_rishta/app/core/services/env_config_service.dart';
import 'package:assaan_rishta/app/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../viewmodels/auth_service.dart';
import '../../../viewmodels/chat_list_viewmodel.dart';
import '../../../viewmodels/chat_viewmodel.dart';
import '../../../views/bottom_nav/export.dart';
import '../../../views/chat/chatting_view.dart';
import '../../../views/chat/export.dart';
import '../../export.dart';
import 'delivery_confirmation_service.dart';

class NotificationServices {
  static bool _isNavigating = false;
  static String? _lastNavigatedUserId;
  static DateTime? _lastNavigationTime;

  static String? _currentSessionId;
  static DateTime? _sessionStartTime;

  // Initialize session when user logs in
  static void initializeSession(String userId) {
    _currentSessionId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    _sessionStartTime = DateTime.now();
    debugPrint(' New notification session initialized: $_currentSessionId');
    // Check for any pending deliveries when user logs in
    DeliveryConfirmationService.processAllPendingDeliveries(userId);
  }

  // Clear session on logout
  static void clearSession() {
    _currentSessionId = null;
    _sessionStartTime = null;
    debugPrint(' Notification session cleared');
  }
  // Map to store messages for each sender
  static final Map<String, List<String>> _senderMessages = {};
  static final Map<String, int> _senderNotificationIds = {};

  // Store pending notification data for app launch
  static RemoteMessage? _pendingNotification;
  static bool _hasPendingNavigation = false;

  // Add method to check and handle pending navigation
  static Future<void> checkPendingNavigation() async {
    if (_hasPendingNavigation && _pendingNotification != null) {
      debugPrint(' Processing pending notification navigation...');
      _hasPendingNavigation = false;
      final tempNotification = _pendingNotification;
      _pendingNotification = null;

      // Small delay to ensure app is ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Create a minimal context or use Get.context if available
      if (Get.context != null) {
        await NotificationServices().handleMessage(Get.context!, tempNotification!);
      }
    }
  }


  // NEW: Validate if notification belongs to current user
  static Future<bool> _validateNotificationForCurrentUser(RemoteMessage message) async {
    try {
      final authService = AuthService.instance;

      // Check if user is logged in
      if (!authService.isUserLoggedIn.value || authService.userId == null) {
        debugPrint(' No user logged in, rejecting notification');
        return false;
      }

      final currentUserId = authService.userId.toString();
      final receiverId = message.data['receiverId'] ?? message.data['targetUserId'];
      final senderId = message.data['senderId'];

      // NEW: Get notification metadata
      final notificationTimestamp = message.data['timestamp'];
      final notificationSessionId = message.data['sessionId'];

      debugPrint(' Enhanced notification validation:');
      debugPrint('   Current User ID: $currentUserId');
      debugPrint('   Current Session ID: $_currentSessionId');
      debugPrint('   Session Start Time: $_sessionStartTime');
      debugPrint('   Notification Receiver ID: $receiverId');
      debugPrint('   Notification Sender ID: $senderId');
      debugPrint('   Notification Timestamp: $notificationTimestamp');
      debugPrint('   Notification Session ID: $notificationSessionId');

      if (senderId != null && senderId == currentUserId) {
        debugPrint(' Notification is from current user (self-notification), rejecting');
        return false;
      }
      // Check if notification is for current user
      // if (receiverId == null || receiverId.isEmpty) {
      //   debugPrint(' No receiverId in notification data');
      //   return false;
      // }
      // 2. SESSION VALIDATION: Check if notification belongs to current session
      if (_sessionStartTime != null && notificationTimestamp != null) {
        try {
          final notificationTime = DateTime.fromMillisecondsSinceEpoch(
              int.parse(notificationTimestamp)
          );

          // Reject notifications from before current login session
          if (notificationTime.isBefore(_sessionStartTime!)) {
            debugPrint(' Old notification rejected: Received before current login session');
            debugPrint('   Notification time: $notificationTime');
            debugPrint('   Session start time: $_sessionStartTime');
            return false;
          }
        } catch (e) {
          debugPrint(' Could not parse notification timestamp: $e');
          // If we can't parse timestamp, be conservative and reject old-looking notifications
          // Allow only very recent notifications (within last 5 minutes)
          final now = DateTime.now();
          if (_sessionStartTime != null && now.difference(_sessionStartTime!).inMinutes > 5) {
            debugPrint(' Rejecting potentially old notification due to unparseable timestamp');
            return false;
          }
        }
      }

      // // 3. ENHANCED USER VALIDATION: Check if receiverId matches current user
      // if (receiverId != null && receiverId.isNotEmpty) {
      //   if (receiverId != currentUserId) {
      //     debugPrint(' Notification for different user: Expected $currentUserId, got $receiverId');
      //     return false;
      //   }
      //   debugPrint(' Notification validated via receiverId match');
      //   return true;
      // }

      // 4. FALLBACK VALIDATION: If no receiverId, do additional checks
      if (senderId == null || senderId.isEmpty) {
        debugPrint(' No sender ID in notification data');
        return false;
      }

      // 5. DOUBLE-CHECK CURRENT USER: Verify user hasn't changed
      try {
        final currentAuthUserId = AuthService.instance.userId?.toString();
        if (currentAuthUserId != currentUserId) {
          debugPrint(' User context changed during validation');
          return false;
        }
      } catch (e) {
        debugPrint(' Error verifying current user context: $e');
        return false;
      }

      // 6. SENDER EXISTENCE VALIDATION
      try {
        final senderDoc = await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(senderId)
            .get();

        if (!senderDoc.exists) {
          debugPrint(' Sender user does not exist: $senderId');
          return false;
        }

        debugPrint(' Enhanced notification validated: From $senderId to $currentUserId');
        return true;

      } catch (e) {
        debugPrint(' Error validating sender existence: $e');
        return false;
      }

    } catch (e) {
      debugPrint(' Error in enhanced notification validation: $e');
      return false;
    }
  }

  // NEW: Additional validation to check if sender exists in current user's chat list
  static Future<bool> _validateSenderForCurrentUser(String senderId) async {
    try {
      final authService = AuthService.instance;
      if (!authService.isUserLoggedIn.value || authService.userId == null) {
        return false;
      }

      final currentUserId = authService.userId.toString();

      // Check if sender exists in current user's Firestore document
      final userDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        debugPrint(' Current user document not found in Firestore');
        return false;
      }

      // Additional check: verify sender exists in global users
      final senderDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(senderId)
          .get();

      if (!senderDoc.exists) {
        debugPrint(' Sender user does not exist in Firestore');
        return false;
      }

      debugPrint(' Sender validation passed');
      return true;

    } catch (e) {
      debugPrint(' Error validating sender: $e');
      return false;
    }
  }

  static Future<String> getAccessToken() async {
    // Load Firebase Service Account credentials from environment variables
    // This is MUCH more secure than hardcoding credentials
    final Map<String, String> serviceAccountJson = EnvConfig.getFirebaseServiceAccountJson();
    
    // Validate that credentials are loaded
    if (serviceAccountJson['private_key']?.isEmpty ?? true) {
      AppLogger.error('Firebase Service Account credentials not found in .env file!');
      AppLogger.error('Please add FIREBASE_SERVICE_ACCOUNT_* variables to your .env file');
      throw Exception('Firebase Service Account credentials not configured');
    }
    
    // Validate PEM format
    final privateKey = serviceAccountJson['private_key']!;
    if (!privateKey.contains('-----BEGIN PRIVATE KEY-----') || 
        !privateKey.contains('-----END PRIVATE KEY-----')) {
      AppLogger.error('Invalid private key format! Missing PEM markers.');
      AppLogger.error('Private key must start with -----BEGIN PRIVATE KEY----- and end with -----END PRIVATE KEY-----');
      AppLogger.error('Check FIREBASE_NOTIFICATION_FIX.md for proper format');
      throw Exception('Invalid Firebase private key format - missing PEM markers');
    }
    
    AppLogger.success('Firebase Service Account credentials loaded from environment');
    
    final List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    
    try {
      http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );
      
      auth.AccessCredentials credentials =
      await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );
      
      client.close();
      AppLogger.success('Firebase access token obtained successfully');
      return credentials.accessToken.data;
    } catch (e) {
      AppLogger.error('Error obtaining Firebase access token', e);
      rethrow;
    }
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  initLocalNotifications(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          handleMessage(context, message);
        });
  }
  // Confirm delivery for foreground messages
  Future<void> confirmForegroundMessageDelivery({
    required String senderId,
    required String receiverId,
    required String messageTimestamp,
  }) async {
    try {
      final chatController = Get.find<ChatViewModel>();

      // If user is in chat with sender, it's already handled
      if (chatController.selectedUser.value?.id == senderId) {
        debugPrint('User is in chat, delivery already handled');
        return;
      }

      // Otherwise, confirm delivery
      final conversationId = getConversationId(senderId, receiverId);
      final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .collection('messages')
          .doc(messageTimestamp)
          .update({
        'delivered': deliveredTime,
        'status': 'delivered',
        'deliveryPending': false,
      });

      debugPrint('✅ Foreground message delivery confirmed');
    } catch (e) {
      debugPrint('❌ Error confirming foreground delivery: $e');
    }
  }
  String getConversationId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) <= 0) {
      return '${userId1}_$userId2';
    } else {
      return '${userId2}_$userId1';
    }
  }
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Logger().d("notifications title:${notification!.title}");
      Logger().d("notifications body:${notification.body}");
      Logger().d('data:${message.data.toString()}');
// Confirm delivery when message received in foreground
      final data = message.data;
      final senderId = data['senderId'] as String?;
      final messageTimestamp = data['timestamp'] as String?;
      final receiverId = data['receiverId'] as String?;

      // if (senderId != null && messageTimestamp != null && receiverId != null) {
      //   await confirmForegroundMessageDelivery(
      //   senderId: senderId,
      //   receiverId: receiverId,
      //   messageTimestamp: messageTimestamp,
      //   );
      // }
      if (senderId != null && messageTimestamp != null && receiverId != null) {
        // Check if user is logged in and is the intended recipient
        final authService = AuthService.instance;
        if (authService.isUserLoggedIn.value &&
            authService.userId?.toString() == receiverId) {

          // Mark as delivered immediately
          await markMessageAsDeliveredImmediately(
            senderId: senderId,
            receiverId: receiverId,
            messageTimestamp: messageTimestamp,
          );
        }
      }
      // Initialize local notifications for both platforms
      initLocalNotifications(context, message);
      
      if (Platform.isIOS) {
        // Set foreground presentation options for iOS
        forGroundMessage();
      }
      
      // Show notification for both platforms
      showNotification(message);
    });
  }

// Add this new method to notification_service.dart
  Future<void> markMessageAsDeliveredImmediately({
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

          debugPrint('✅ Message marked as delivered immediately on receipt');
        }
      }
    } catch (e) {
      debugPrint('❌ Error marking message as delivered immediately: $e');
    }
  }
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    // FIXED: Validate notification before showing
    final isValid = await _validateNotificationForCurrentUser(message);
    if (!isValid) {
      debugPrint('❌ Notification validation failed, not showing notification');
      return;
    }

    final senderId = message.data['senderId'] ?? 'unknown_sender';
    final notificationTitle = message.notification!.title.toString();
    final notificationBody = message.notification!.body.toString();
    final senderImage = message.data['senderImage'];

    // Add the new message to the list for this sender
    if (!_senderMessages.containsKey(senderId)) {
      _senderMessages[senderId] = [];
    }
    _senderMessages[senderId]!.add(notificationBody);

    // Construct the grouped message body
    String groupedBody;
    if (_senderMessages[senderId]!.length > 1) {
      groupedBody = _senderMessages[senderId]!.join('\n');
    } else {
      groupedBody = notificationBody;
    }

    // Get or generate a unique notification ID for this sender
    int notificationId;
    if (_senderNotificationIds.containsKey(senderId)) {
      notificationId = _senderNotificationIds[senderId]!;
    } else {
      notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000).toInt();
      _senderNotificationIds[senderId] = notificationId;
    }

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      senderId,
      'Messages from $notificationTitle',
      importance: Importance.max,
      showBadge: true,
      groupId: senderId,
    );

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: 'Channel for messages from $notificationTitle',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      groupKey: senderId,
      largeIcon: senderImage != null && senderImage.isNotEmpty ? FilePathAndroidBitmap(senderImage) : null,
      styleInformation: _senderMessages[senderId]!.length > 1
          ? InboxStyleInformation(
        _senderMessages[senderId]!,
        contentTitle: notificationTitle,
        summaryText: '${_senderMessages[senderId]!.length} new messages',
      )
          : null,
    );

    final DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(presentAlert: true, presentBadge: true, threadIdentifier: senderId);

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        notificationId, notificationTitle, groupedBody, notificationDetails,
      );
    });
  }

  // Store FCM token for a user
  static Future<void> storeFCMToken(String userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || userId.isEmpty) return;

      debugPrint('💾 Storing FCM token for user: $userId');

      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .update({
        'push_token': token,
        'token_updated_at': FieldValue.serverTimestamp(),
        'platform': Platform.isIOS ? 'iOS' : 'Android',
      });

      debugPrint('✅ FCM token stored successfully');
    } catch (e) {
      debugPrint('❌ Error storing FCM token: $e');
    }
  }

  // Remove FCM token when user logs out
  static Future<void> removeFCMToken(String userId) async {
    try {
      if (userId.isEmpty) return;

      debugPrint('🗑️ Removing FCM token for user: $userId');

      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .update({
        'push_token': FieldValue.delete(),
        'token_updated_at': FieldValue.serverTimestamp(),
      });

      await FirebaseMessaging.instance.deleteToken();

      debugPrint('✅ FCM token removed successfully');
    } catch (e) {
      debugPrint('❌ Error removing FCM token: $e');
    }
  }

  Future<String> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();

      final authService = AuthService.instance;
      if (authService.isUserLoggedIn.value && authService.userId != null) {
        await storeFCMToken(authService.userId.toString());
      }

      return token ?? '';
    } catch (e) {
      debugPrint('Error getting device token: $e');
      return '';
    }
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((String token) async {
      debugPrint('🔄 FCM Token refreshed');

      final authService = AuthService.instance;
      if (authService.isUserLoggedIn.value && authService.userId != null) {
        await storeFCMToken(authService.userId.toString());
      }
    });
  }

  static void clearMessagesForSender(String senderId) {
    _senderMessages.remove(senderId);
  }

  // IMPROVED: Handle message with user validation
  Future<void> handleMessage(BuildContext context, RemoteMessage message) async {
    debugPrint('🔔 Notification clicked with data: ${message.data}');
    debugPrint('📍 Current route when handling: ${Get.currentRoute}');

    // FIXED: First validate if notification belongs to current user
    final isValidForCurrentUser = await _validateNotificationForCurrentUser(message);
    if (!isValidForCurrentUser) {
      debugPrint('❌ Notification does not belong to current user, ignoring...');
      return;
    }

    if (message.data['type'] == 'chat') {
      final senderId = message.data['senderId'];
      final senderName = message.data['senderName'];
      final senderImage = message.data['senderImage'];
      final senderEmail = message.data['senderEmail'];

      debugPrint('📱 Sender ID: $senderId, Name: $senderName');

      if (senderId != null && senderId.isNotEmpty && senderName != null) {

        // FIXED: Additional validation to check if sender is valid for current user
        final isSenderValid = await _validateSenderForCurrentUser(senderId);
        if (!isSenderValid) {
          debugPrint('❌ Sender validation failed, ignoring notification');
          return;
        }

        clearMessagesForSender(senderId);

        // Check if app is still initializing (splash screen or initial routes)
        if (_isAppInitializing()) {
          debugPrint('⏳ App still initializing, storing notification for later');
          _pendingNotification = message;
          _hasPendingNavigation = true;
          return;
        }

        if (_isNavigating) {
          final now = DateTime.now();
          if (_lastNavigationTime != null &&
              now.difference(_lastNavigationTime!).inSeconds > 5) {
            debugPrint('⚠️ Resetting stuck navigation state');
            _resetNavigationState();
          } else {
            debugPrint('⚠️ Navigation already in progress, skipping');
            return;
          }
        }

        if (_lastNavigatedUserId == senderId &&
            _lastNavigationTime != null) {
          final now = DateTime.now();
          if (now.difference(_lastNavigationTime!).inSeconds < 2) {
            debugPrint('⚠️ Preventing duplicate navigation to same user');
            return;
          }
        }

        try {
          debugPrint('🚀 Creating ChatUser from notification data...');

          final chatUser = ChatUser(
            id: senderId,
            name: senderName,
            image: senderImage ?? '',
            email: senderEmail ?? '',
            about: '',
            createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
            lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
            lastMessage: DateTime.now().millisecondsSinceEpoch.toString(),
            isInside: false,
            isOnline: false,
            isMobileOnline: false,
            isWebOnline: false,
            pushToken: '',
            blockedUsers: [],
          );

          debugPrint('✅ ChatUser created: ${chatUser.name}');

          await _navigateToChatSafely(chatUser);

        } catch (e) {
          debugPrint('❌ Error in notification handling: $e');
          _resetNavigationState();
          _navigateToBottomNav();
        }
      } else {
        debugPrint('⚠️ Incomplete notification data');
        _navigateToBottomNav();
      }
    }
  }

  // Check if app is still initializing
  bool _isAppInitializing() {
    final currentRoute = Get.currentRoute;
    return currentRoute == '/' ||
        currentRoute.isEmpty ||
        currentRoute.contains('/splash') ||
        currentRoute.contains('Splash');
  }

  static void _resetNavigationState() {
    _isNavigating = false;
    debugPrint('🔄 Navigation state reset');
  }

  // bool _shouldPreventNavigation(String userId) {
  //   final now = DateTime.now();
  //
  //   if (_isNavigating) {
  //     return true;
  //   }
  //
  //   if (_lastNavigatedUserId == userId &&
  //       _lastNavigationTime != null &&
  //       now.difference(_lastNavigationTime!).inSeconds < 2) {
  //     return true;
  //   }
  //
  //   return false;
  // }

  // IMPROVED: Navigation with terminated state handling
  Future<void> _navigateToChatSafely(ChatUser chatUser) async {
    try {
      _isNavigating = true;
      _lastNavigatedUserId = chatUser.id;
      _lastNavigationTime = DateTime.now();

      debugPrint('🏠 Starting safe navigation to chat...');
      debugPrint('📍 Current route: ${Get.currentRoute}');

      // Ensure controllers are available
      if (!Get.isRegistered<ChatViewModel>()) {
        Get.put(ChatViewModel(), permanent: true);
      }
      if (!Get.isRegistered<ChatListController>()) {
        Get.put(ChatListController(), permanent: true);
      }

      final chatController = Get.find<ChatViewModel>();
      final chatListController = Get.find<ChatListController>();

      chatListController.resetAllStates();

      if (chatController.isChattingWithUser(chatUser.id)) {
        debugPrint('✅ Already in chat with user ${chatUser.name}');
        _resetNavigationState();
        return;
      }

      // FIXED: Only add sender to chat list if validation passed
      await _addSenderToChatList(chatUser.id);

      bool? isBlocked;
      bool? isBlockedByOther;

      try {
        final results = await Future.wait([
          chatController.isUserBlocked(chatUser.id),
          chatController.isBlockedByFriend(chatUser.id),
        ]);
        isBlocked = results[0];
        isBlockedByOther = results[1];
      } catch (e) {
        debugPrint('Error checking block status: $e');
      }

      final currentRoute = Get.currentRoute;

      // Special handling for app launch from terminated state
      // if (_isAppInitializing() || currentRoute == '/' || currentRoute.isEmpty) {
      //   debugPrint('🚀 App launched from terminated state, direct navigation');
      //   await _navigateDirectlyFromTerminated(
      //     chatUser,
      //     chatListController,
      //     isBlocked,
      //     isBlockedByOther,
      //   );
      // }
      // else
        if (_isInChattingView(currentRoute)) {
        await _switchBetweenChats(
          chatUser,
          chatController,
          chatListController,
          isBlocked,
          isBlockedByOther,
        );
      }
      else if (currentRoute.contains('/bottom-nav')) {
        await _navigateFromBottomNav(
          chatUser,
          chatListController,
          isBlocked,
          isBlockedByOther,
        );
      }
      else {
        await _navigateFromOtherScreen(
          chatUser,
          chatListController,
          isBlocked,
          isBlockedByOther,
        );
      }

      debugPrint('✅ Navigation completed successfully');

    } catch (e) {
      debugPrint('❌ Error navigating: $e');

      if (Get.isRegistered<ChatListController>()) {
        final listController = Get.find<ChatListController>();
        listController.resetAllStates();
      }

      _navigateToBottomNav();
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _resetNavigationState();

        if (Get.isRegistered<ChatListController>()) {
          final listController = Get.find<ChatListController>();
          if (listController.isLoading.value ||
              listController.isRefreshing.value ||
              listController.isNavigatingToChat.value) {
            listController.resetAllStates();
          }
        }
      });
    }
  }

  // NEW: Direct navigation from terminated state
  Future<void> _navigateDirectlyFromTerminated(
      ChatUser chatUser,
      ChatListController chatListController,
      bool? isBlocked,
      bool? isBlockedByOther,
      ) async {
    debugPrint('🚀 Direct navigation from terminated state');

    // Clear all existing routes and navigate directly
    Get.offAll(
          () => ChattingView(
        user: chatUser,
        isBlocked: isBlocked,
        isBlockedByOther: isBlockedByOther,
      ),
      transition: Transition.noTransition, // No animation for faster load
    );

    // After navigation, add bottom nav to stack for back navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      // This ensures user can go back to bottom nav
      Get.offAll(
            () => const BottomNavView(index: 2),
        predicate: (route) => false,
      );
      Get.to(
            () => ChattingView(
          user: chatUser,
          isBlocked: isBlocked,
          isBlockedByOther: isBlockedByOther,
        ),
        preventDuplicates: true,
      );
    });
  }

  bool _isInChattingView(String route) {
    return route.startsWith('/chatting_view/') ||
        route.contains('/chatting-view') ||
        route.contains('/ChattingView') ||
        route == AppRoutes.CHATTING_VIEW;
  }

  Future<void> _switchBetweenChats(
      ChatUser chatUser,
      ChatViewModel chatController,
      ChatListController chatListController,
      bool? isBlocked,
      bool? isBlockedByOther,
      ) async {
    debugPrint('🔄 Switching from one chat to another...');

    chatListController.isNavigatingToChat.value = true;

    Get.offNamed(
      AppRoutes.chattingViewWithUser(chatUser.id),
      arguments: {
        'chatUser': chatUser,
        'isBlocked': isBlocked,
        'isBlockedByOther': isBlockedByOther,
      },
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      chatListController.isNavigatingToChat.value = false;
    });
  }

  Future<void> _navigateFromBottomNav(
      ChatUser chatUser,
      ChatListController chatListController,
      bool? isBlocked,
      bool? isBlockedByOther,
      ) async {
    debugPrint('📱 Navigating from bottom nav to chat...');

    chatListController.isNavigatingToChat.value = true;

    await Get.to(
          () => ChattingView(
        user: chatUser,
        isBlocked: isBlocked,
        isBlockedByOther: isBlockedByOther,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
      preventDuplicates: true,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      chatListController.isNavigatingToChat.value = false;
    });
  }

  Future<void> _navigateFromOtherScreen(
      ChatUser chatUser,
      ChatListController chatListController,
      bool? isBlocked,
      bool? isBlockedByOther,
      ) async {
    debugPrint('🚀 Navigating from other screen to chat...');

    chatListController.isNavigatingToChat.value = true;
    //Get.offNamed(AppRoutes.BOTTOM_NAV2, arguments: 2);

    //Future.delayed(const Duration(milliseconds: 100), () {
      Get.to(
            () => ChattingView(
          user: chatUser,
          isBlocked: isBlocked,
          isBlockedByOther: isBlockedByOther,
        ),
      );

     // Future.delayed(const Duration(milliseconds: 200), () {
        chatListController.isNavigatingToChat.value = false;
     // });
   // });
  }

  void _navigateToBottomNav() {
    if (!_isNavigating) {
      _isNavigating = true;
      Get.offAll(() => const BottomNavView(index: 2))?.then((_) {
        _resetNavigationState();
      });
    }
  }

  // FIXED: Only add sender to chat list if validation passed
  Future<void> _addSenderToChatList(String senderId) async {
    try {
      debugPrint('➕ Adding sender $senderId to chat list...');

      final authService = AuthService.instance;
      if (!authService.isUserLoggedIn.value || authService.userId == null) {
        debugPrint('❌ No user logged in, cannot add sender to chat list');
        return;
      }

      final currentUserId = authService.userId.toString();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Double-check: Only add if current user is logged in
      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(senderId)
          .set({
        'last_message_time': timestamp,
        'added_at': timestamp,
        'added_by_notification': true, // Track that this was added via notification
      }, SetOptions(merge: true));

      debugPrint('✅ Sender added to chat list for user: $currentUserId');
    } catch (e) {
      debugPrint('❌ Error adding sender to chat list: $e');
    }
  }

  // IMPROVED: Setup interaction with better terminated state handling
  Future<void> setupInteractMessage(BuildContext context) async {
    _resetNavigationState();

    // Handle app launch from terminated state
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('🔔 App launched from notification (terminated state)');

      // FIXED: Validate notification before storing
      final isValid = await _validateNotificationForCurrentUser(initialMessage);
      if (!isValid) {
        debugPrint('❌ Initial notification not valid for current user, ignoring');
        return;
      }

      // Store for processing after app initializes
      _pendingNotification = initialMessage;
      _hasPendingNavigation = true;

      // Try to handle immediately if app is ready
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_hasPendingNavigation && _pendingNotification != null) {
          handleMessage(context, _pendingNotification!);
        }
      });
    }

    // Handle app in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (_isNavigating) {
        debugPrint('⚠️ Resetting navigation state before handling new message');
        _resetNavigationState();
      }
      handleMessage(context, event);
    });
  }

  String? _extractUserIdFromRoute(String route) {
    try {
      if (route.contains('/chatting_view/')) {
        final parts = route.split('/chatting_view/');
        if (parts.length > 1) {
          final userIdPart = parts[1].split('?')[0];
          return userIdPart.isNotEmpty ? userIdPart : null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error extracting user ID from route: $e');
      return null;
    }
  }
// In NotificationServices class

  // UPDATED: Send notification method with receiverId
  static Future<void> sendNotification({
    required String senderName,
    required String fcmToken,
    required String msg,
    String? senderId,
    String? senderImage,
    String? senderEmail,
    required String receiverId,   // Make receiverId required
    String? messageTimestamp,
  }) async {
    try {
      if (fcmToken.isEmpty || receiverId.isEmpty) {
        debugPrint('⚠️ Cannot send notification: Empty FCM token');
        return;
      }

      if (receiverId.isEmpty) {
        debugPrint('⚠️ Cannot send notification: Empty receiver ID');
        return;
      }

      // Verify receiver exists and has valid token
      final receiverDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(receiverId)
          .get();

      if (!receiverDoc.exists || receiverDoc.data()?['push_token'] == null) {
        debugPrint('⚠️ Receiver $receiverId does not exist or has no push token. Aborting notification.');
        return;
      }
      if (receiverDoc.data()?['push_token'] != fcmToken) {
        debugPrint('⚠️ FCM token mismatch for receiver $receiverId. Aborting notification.');
        return;
      }

      String serverTokenKey = await getAccessToken();
      // Use project ID from environment variables instead of hardcoding
      final projectId = EnvConfig.firebaseServiceAccountProjectId;
      String endPoint = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";
      
      if (projectId.isEmpty) {
        AppLogger.error('Firebase project ID not configured');
        return;
      }
      //final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      Map<String, dynamic> message = {
        "message": {
          "token": fcmToken,
          "notification": {
            "title": senderName,
            "body": msg,
          },
          "data": {
            "type": "chat",
            "senderId": senderId ?? '',
            "senderName": senderName,
            "senderImage": senderImage ?? '',
            "senderEmail": senderEmail ?? '',
            "receiverId": receiverId, // FIXED: Include receiverId in data
            "targetUserId": receiverId,
            "timestamp": messageTimestamp?? '',
            // "timestamp": currentTimestamp?? '',
            "sessionId":_currentSessionId??"",// Alternative key for validation
            "notificationId": '${senderId}_${receiverId}_$messageTimestamp', // Unique ID
          },
        }
      };

      http.Response res = await http.post(
        Uri.parse(endPoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverTokenKey',
        },
        body: jsonEncode(message),
      );

      Logger().d('status code => ${res.statusCode}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        Logger().d('message send success');
        debugPrint('✅ Notification sent successfully to user: $receiverId');
        debugPrint('   Timestamp: $messageTimestamp');
        debugPrint('   Session: $_currentSessionId');
      } else {
        Logger().d('response ${res.body}');
        Logger().d('message send failed');
        debugPrint('❌ Failed to send notification: ${res.body}');

        // Handle UNREGISTERED token error
        if (res.body.contains('UNREGISTERED')) {
          debugPrint('🗑️ Detected unregistered FCM token for user $receiverId. Removing it.');
          await FirebaseFirestore.instance
              .collection('Hamid_users')
              .doc(receiverId)
              .update({'push_token': FieldValue.delete()});
        }
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  Future forGroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}