// notification_service.dart - FIXED VERSION

import 'dart:convert';
import 'dart:io';

import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../domain/export.dart';
import '../../../viewmodels/auth_service.dart';
import '../../../viewmodels/chat_list_viewmodel.dart';
import '../../../viewmodels/chat_viewmodel.dart';
import '../../../views/bottom_nav/export.dart';
import '../../../views/chat/export.dart';
import '../../export.dart';

class NotificationServices {
  static Future<String> getAccessToken() async {
    Map<String, String> serviceAccountJson = {
      "type": "service_account",
      "project_id": "asaan-rishta-chat",
      "private_key_id": "3d239983797c2f900d66aeb4e00e4940f473cd2a",
      "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCv2DHlFCO012eI\nZYGub2NeLdA/IDCGVbWdF/rtRx3OOFA2xqqds2qIBXjvrpamvhW4mVwtK2H2K8y2\nqb60UegF45RO3jjGUNhTImHFUaU0i8o4l2qe6w+NcE8qg+BZKNBP0jYmgP7X5HYU\ndQfYqZcFsCQd1MSkpkHE5SLxkwwbIbHTS608PCkMexBSLdbnngx1yXlTqnJd0RUo\ntUSJzC2ETeIdFVXvw/XTBcOhXTXjmEecKYNISfW8EOlIJt0SvB3fxmLJiEqw1ZGs\nUu/tt0KGy2mAX4pbo8VckGbqBKk1iS4r5NPaAfANVjR/+Nutru4oFG0WmQW09iMo\nEcn186DhAgMBAAECggEABFB2q20cwejry+55Ib5vAsJXHthfZmlbjgvWwsv1EtBi\nA/EIgjti3ozbUm6fOL62zddZ6gwLoJCDKptkL9yHV78lXjDAtflpcFM6cL7bwbv5\nCX3KDnV8FYNbFuMCze802rOAs33EWufKn55+M3o4N8oSPcbgzv0bBZ2dV43c/Pyi\ne/5C+u4I79VdFK95exzII7la21kw1d2WEk8YZErSyyYoph0gE2Tv2o3XLO+x4EkC\nsbHOCr8r2b2aCw7bRO0D050LnDbIU530kMb3Jbt12qGFppGZKTAMr5fwetwz2Gcm\nmuOaNQsIL/UQ3kIrF0CRZv6FwQGvFPQgHG6GAnhr8QKBgQDte9GegjT3ICoM/5hN\npe/Sq+4B6ttpR8nrnoCXh1/UL2gjb8Bc/7lKEaBtP9pN0bcZrVWAhk9/Ybjk4qb4\nF89XKPIBkGsxpy4xVPR6v4n+hB5ofjN7NpB5k93MrWr+S/4olLSlfAwIuymREbHz\no2g8asx8Zh9Av8A/WAtIGAkLcQKBgQC9jg6BXgg2F+6YTj8tjrx8FCZNYBqzYdgq\nXNBzbt7tQx0AxosBCMv9/7cx0WgwZ3kedPaAd0FD94qmi+e1A1FbWzHXIG7qWG2L\nRWc01oOz+vlM5cDVmDXlBVjEM1tfsEcbg/NRUgL2QjP9ZwwIV7Tkk8TcWweNRaiC\ny3ThDjzUcQKBgGYZpbWQJVVZ7rpH6SL5BHJ+mIUag9pvktBKBN8gxIJlH1Cc6wcQ\nqoi9q0tM+H4ce6v+aZQoKmWJjgRZrY9cLTg70k/51xwx1BpBfBqJ3rod8zTZjSib\n/OFIQUOOC0HpSgwIYuICwum+DdDg2rD0wAu5ntCc1zLvPaf+IluMedcBAoGABtWn\najy0uRaV0MIJfyAFZcfoNaQAcnVVsPlVvsPBn/ZqhkuiWXAywr7EoTQ2uIASmumG\ntc0W+ldjlWu3+AvdlBiurF4MAcEceggPl5UgfI3RDVe/YzQwxUgzEifz5Hhbp/9S\n95yoZK6wZzOe+HIJILC/SV6y4AIh+E1TsoWr5dECgYBXu+6dfidFJ6R6bjjFOtKO\nP/vhSfhEAPG1crfg8QcepbThVTcYQv0yYTrd9aVQ2+t3WY8QrG91WI77qsujvrDg\nWyr8sRNtvkD8sDrc7LXbHpkGnscPtkLv3ANmdjaQcg/nrBY0Ng6GmwSGf/DimpJD\n8GifHfQRhLAwKtDDjbRF+g==\n-----END PRIVATE KEY-----\n",
      "client_email":
      "asaan-rishta-chat@asaan-rishta-chat.iam.gserviceaccount.com",
      "client_id": "114478927019035620233",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
      "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/asaan-rishta-chat%40asaan-rishta-chat.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
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
    return credentials.accessToken.data;
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

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      Logger().d("notifications title:${notification!.title}");
      Logger().d("notifications body:${notification.body}");
      Logger().d('data:${message.data.toString()}');

      if (Platform.isIOS) {
        forGroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
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
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id.toString(), channel.name.toString(),
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
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

      // Remove from Firestore
      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .update({
        'push_token': FieldValue.delete(),
        'token_updated_at': FieldValue.serverTimestamp(),
      });

      // Delete local token
      await FirebaseMessaging.instance.deleteToken();

      debugPrint('✅ FCM token removed successfully');
    } catch (e) {
      debugPrint('❌ Error removing FCM token: $e');
    }
  }
  // Update the getDeviceToken method to store it automatically
  Future<String> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();

      // Store token if user is logged in
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

  // Handle token refresh
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((String token) async {
      debugPrint('🔄 FCM Token refreshed');

      // Update token if user is logged in
      final authService = AuthService.instance;
      if (authService.isUserLoggedIn.value && authService.userId != null) {
        await storeFCMToken(authService.userId.toString());
      }
    });
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  // FIXED: Complete notification handling
  void handleMessage(BuildContext context, RemoteMessage message) {
    debugPrint('🔔 Notification clicked with data: ${message.data}');

    if (message.data['type'] == 'chat') {
      final senderId = message.data['senderId'];
      final senderName = message.data['senderName'];
      final senderImage = message.data['senderImage'];
      final senderEmail = message.data['senderEmail'];

      debugPrint('📱 Sender ID: $senderId, Name: $senderName');

      if (senderId != null && senderId.isNotEmpty && senderName != null) {
        try {
          debugPrint('🚀 Creating ChatUser from notification data...');

          // Create ChatUser object from notification data
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

          // FIXED: Direct navigation without complex logic
          _navigateToChat(chatUser);

        } catch (e) {
          debugPrint('❌ Error in notification handling: $e');
          Get.offAll(() => const BottomNavView(index: 1));
        }
      } else {
        debugPrint('⚠️ Incomplete notification data');
        Get.offAll(() => const BottomNavView(index: 1));
      }
    }
  }

  // FIXED: Direct navigation method
  void _navigateToChat(ChatUser chatUser) async {
    try {
      debugPrint('🏠 Starting navigation to chat...');

      // // Ensure we have the chat controller
      // if (!Get.isRegistered<ChatViewModel>()) {
      //   Get.put(ChatViewModel(), permanent: true);
      // }
      // if (!Get.isRegistered<ChatListController>()) {
      //   Get.lazyPut<ChatListController>(() => ChatListController());
      // }

      // Add user to chat list first
      await _addSenderToChatList(chatUser.id);

      // Small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 10));

      // Navigate directly to chat
      Get.offAll(() => const BottomNavView(index: 1));

      // Wait a bit for the chat list to load
      await Future.delayed(const Duration(milliseconds:100));

      // Now navigate to specific chat
      //Get.to(AppRoutes.CHATTING_VIEW, arguments: chatUser);
       Get.to(() => ChattingView(user: chatUser));

      debugPrint('✅ Navigation completed successfully');

    } catch (e) {
      debugPrint('❌ Error navigating to chat: $e');
      // Fallback to chat list
      Get.offAll(() => const BottomNavView(index: 1));
    }
  }

  // Helper function to add sender to chat list
  Future<void> _addSenderToChatList(String senderId) async {
    try {
      debugPrint('➕ Adding sender $senderId to chat list...');

      final currentUserId = Get.find<UserManagementUseCase>().getUserId().toString();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Add sender to current user's my_users collection
      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(senderId)
          .set({
        'last_message_time': timestamp,
        'added_at': timestamp,
      }, SetOptions(merge: true));

      debugPrint('✅ Sender added to chat list');
    } catch (e) {
      debugPrint('❌ Error adding sender to chat list: $e');
    }
  }

  // Send notification method
// Modified sendNotification to check if receiver has valid token
  static Future<void> sendNotification({
    required String senderName,
    required String fcmToken,
    required String msg,
    String? senderId,
    String? senderImage,
    String? senderEmail,
    String? receiverId,
  }) async {
    try {
      // Check if token is valid (not empty)
      if (fcmToken.isEmpty) {
        debugPrint('⚠️ Cannot send notification: Empty FCM token');
        return;
      }

      // If receiverId is provided, verify they're still logged in
      if (receiverId != null && receiverId.isNotEmpty) {
        final receiverDoc = await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(receiverId)
            .get();

        if (!receiverDoc.exists || receiverDoc.data()?['push_token'] == null) {
          debugPrint('⚠️ Receiver has no valid push token');
          return;
        }
      }

      String serverTokenKey = await getAccessToken();
      String endPoint = "https://fcm.googleapis.com/v1/projects/asaan-rishta-chat/messages:send";

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
      } else {
        Logger().d('response ${res.body}');
        Logger().d('message send failed');
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