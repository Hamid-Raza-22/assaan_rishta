// firebase_service.dart - Fixed for optimal performance and proper navigation

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/export.dart';
import '../../export.dart';
import 'export.dart';

const fireStoregeUrl = "https://firebasestorage.googleapis.com";
const fcm = "https://fcm.googleapis.com/fcm/send";

class FirebaseService {
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing cloud firestore database
  static FirebaseStorage storage = FirebaseStorage.instance;

  static String get imageUrl => me!.image;

  // current user
  static ChatUser? me;
  static final useCase = Get.find<UserManagementUseCase>();
  static final systemUseCase = Get.find<SystemConfigUseCase>();

  // for accessing firebase messaging
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // ADDED: Track app state for proper notification handling
   static bool _isAppInForeground = true;
  static bool _isInChatScreen = false;
  static String? _currentChatUserId;

  // ADDED: App state management
  static void setAppState({bool? isInForeground, bool? isInChat, String? chatUserId}) {
     if (isInForeground != null) _isAppInForeground = isInForeground;
    if (isInChat != null) _isInChatScreen = isInChat;
    if (chatUserId != null) _currentChatUserId = chatUserId;

    debugPrint('📱 App State: Foreground=$_isAppInForeground, InChat=$_isInChatScreen, ChatUser=$_currentChatUserId');
  }

  // for checking if user exist or not?
  static Future<bool> userExists(uid) async =>
      (await firestore.collection('Hamid_users').doc(uid).get()).exists;

  // OPTIMIZED: Faster chat connection
  static Future<bool> addChatUser(String uid) async {
    final data = await firestore.collection('Hamid_users').where('id', isEqualTo: uid).get();

    if (data.docs.isNotEmpty && data.docs.first.id != useCase.getUserId().toString()) {
      final currentUserId = useCase.getUserId().toString();
      final otherUserDocId = data.docs.first.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // BATCH OPERATION for faster execution
      WriteBatch batch = firestore.batch();

      batch.set(
        firestore
            .collection('Hamid_users')
            .doc(currentUserId)
            .collection('my_users')
            .doc(otherUserDocId),
        {
          'last_message_time': timestamp,
          'added_at': timestamp,
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      debugPrint('✅ Chat user added with batch operation');
      return true;
    }
    return false;
  }

  // for getting self info
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('Hamid_users')
        .doc(useCase.getUserId().toString())
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        await FirebaseService.updateActiveStatus(true);
      }
    });
  }

  static Future<ChatUser?> getUserById(String uid, String imageUrl) async {
    final userDoc = await firestore.collection('Hamid_users').doc(uid).get();
    if (userDoc.exists) {
      debugPrint("user data => ${userDoc.data()}");
      await firestore.collection('Hamid_users').doc(uid).update({
        'image': imageUrl,
      });
      return ChatUser.fromJson(userDoc.data()!);
    } else {
      return null;
    }
  }

  // for creating a new user
  static Future<void> createUser({
    required String name,
    required String id,
    required String email,
    required String image,
    required bool isOnline,
    required bool isMobileOnline,
  }) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      image: image,
      about: "Hey, I am using We Chat !!",
      name: name,
      createdAt: time,
      lastActive: time,
      lastMessage: time,
      isInside: false,
      isOnline: isOnline,
      isMobileOnline: isMobileOnline,
      isWebOnline: false,
      id: id,
      pushToken: '',
      email: email,
    );

    debugPrint(id);
    bool isExist = await userExists(id);
    if (!isExist) {
      return await firestore.collection('Hamid_users').doc(id).set(chatUser.toJson());
    }
  }

  // stream for getting all the id of my users from data base
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(currentUID) {
    return firestore
        .collection('Hamid_users')
        .doc(currentUID)
        .collection('my_users')
        .orderBy('last_message_time', descending: true)
        .snapshots();
  }

  // stream for getting all the users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    return firestore
        .collection('Hamid_users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  // stream for getting the user's Information
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo({required String uid}) {
    return firestore
        .collection('Hamid_users')
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  // OPTIMIZED: Better status management
  static Future<void> updateActiveStatus(bool isOnline) async {
    if (me == null) return;

    try {
      await firestore
          .collection('Hamid_users')
          .doc(useCase.getUserId().toString())
          .update({
        'is_online': isOnline,
        'is_mobile_online': isOnline,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        'push_token': me!.pushToken,
      });

      debugPrint('✅ Status updated: ${isOnline ? "Online" : "Offline"}');
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
    }
  }

  static Future<void> updateLastActive() async {
    await firestore
        .collection('Hamid_users')
        .doc(useCase.getUserId().toString())
        .update({
      'last_message': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  static Future<void> insideChatStatus(bool isInside) async {
    // Update local state
    _isInChatScreen = isInside;

    await firestore
        .collection('Hamid_users')
        .doc(useCase.getUserId().toString())
        .update({'is_inside': isInside});

    debugPrint('💬 Chat status updated: ${isInside ? "Inside chat" : "Outside chat"}');
  }

  //update fcm token
  static Future<void> updateFcmToken({fcmToken}) async {
    await firestore
        .collection('Hamid_users')
        .doc(useCase.getUserId().toString())
        .update({'push_token': fcmToken});
  }

  // for getting conversation id
  static String getConversationID(String otherId) {
    String uid = useCase.getUserId().toString();
    String chatRoomId = "";

    if (uid.compareTo(otherId) <= 0) {
      chatRoomId = '${uid}_$otherId';
    } else {
      chatRoomId = '${otherId}_$uid';
    }
    return chatRoomId;
  }

  // stream for gell all the Messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('Hamid_chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // OPTIMIZED: Faster mutual connection
  static Future<void> ensureMutualChatConnection(String senderId, String receiverId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // SINGLE BATCH for better performance
      WriteBatch batch = firestore.batch();

      batch.set(
        firestore
            .collection('Hamid_users')
            .doc(receiverId)
            .collection('my_users')
            .doc(senderId),
        {'last_message_time': timestamp},
        SetOptions(merge: true),
      );

      batch.set(
        firestore
            .collection('Hamid_users')
            .doc(senderId)
            .collection('my_users')
            .doc(receiverId),
        {'last_message_time': timestamp},
        SetOptions(merge: true),
      );

      await batch.commit();
      debugPrint('✅ Mutual connection updated');
    } catch (e) {
      debugPrint('❌ Error in mutual connection: $e');
    }
  }

  // OPTIMIZED: Faster timestamp update
  static Future<void> updateConversationTimestamp(String userId, String otherUserId, String timestamp) async {
    try {
      await firestore
          .collection('Hamid_users')
          .doc(userId)
          .collection('my_users')
          .doc(otherUserId)
          .update({'last_message_time': timestamp});
    } catch (e) {
      debugPrint('❌ Error updating timestamp: $e');
    }
  }

  // OPTIMIZED: Much faster message sending
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    if (me == null) {
      await getSelfInfo();
    }

    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final currentUserId = useCase.getUserId().toString();

    final Message message = Message(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      fromId: currentUserId,
      sent: time,
    );

    try {
      // PARALLEL OPERATIONS for speed
      await Future.wait([
        // 1. Save message
        firestore
            .collection('Hamid_chats/${getConversationID(chatUser.id)}/messages')
            .doc(time)
            .set(message.toJson()),

        // 2. Update timestamps
        updateConversationTimestamp(currentUserId, chatUser.id, time),
        updateConversationTimestamp(chatUser.id, currentUserId, time),

        // 3. Update receiver's last message
        firestore.collection('Hamid_users').doc(chatUser.id).update({
          'last_message': time,
        }),
      ]);

      debugPrint('✅ Message sent successfully');

      // 4. Send notification ONLY if needed (non-blocking)
      _sendNotificationIfNeeded(chatUser, msg, type, currentUserId);

    } catch (e) {
      debugPrint('❌ Error sending message: $e');
    }
  }

  // OPTIMIZED: Smart notification sending
  static Future<void> _sendNotificationIfNeeded(ChatUser chatUser, String msg, Type type, String currentUserId) async {
    try {
      final userDoc = await firestore.collection('Hamid_users').doc(chatUser.id).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final isReceiverOnline = userData['is_online'] as bool? ?? false;
      final isReceiverInChat = userData['is_inside'] as bool? ?? false;
      final fcmToken = userData['push_token'] as String? ?? '';

      // SMART NOTIFICATION LOGIC
      bool shouldSendNotification = fcmToken.isNotEmpty && (
          !isReceiverOnline ||  // User is offline
              !isReceiverInChat ||  // User is online but not in chat
              (!_isAppInForeground) // App is in background
      );

      if (shouldSendNotification) {
        final myToken = await _getFcmToken();
        if (fcmToken != myToken) {
          String senderName = me?.name ?? "User";
          String senderImage = me?.image ?? "";
          String senderEmail = me?.email ?? "";

          await NotificationServices.sendNotification(
            senderName: senderName,
            fcmToken: fcmToken,
            msg: type == Type.text ? msg : 'Photo',
            senderId: currentUserId,
            senderImage: senderImage,
            senderEmail: senderEmail,
            receiverId: chatUser.id,
          );

          debugPrint('📨 Notification sent to ${chatUser.name}');
        }
      } else {
        debugPrint('🔕 Notification skipped - user is active');
      }
    } catch (e) {
      debugPrint('❌ Error in notification: $e');
    }
  }

  static Future<String?> _getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    try {
      await firestore
          .collection('Hamid_chats/${getConversationID(message.fromId)}/messages')
          .doc(message.sent)
          .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        debugPrint('Document not found: ${message.sent}');
      } else {
        rethrow;
      }
    }
  }

  // stream for getting the last message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return firestore
        .collection('Hamid_chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // for sending images in chats
  static Future<void> sendChatImage(String currentUID, ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
            (p0) => log('data transfered: ${p0.bytesTransferred / 1000} kbs'));

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('Hamid_chats/${getConversationID(message.toId)}/messages')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // delete message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('Hamid_chats/${getConversationID(message.toId)}/messages')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    if (Platform.isAndroid) {
      await fMessaging.getToken().then((value) {
        if (value != null) me!.pushToken = value;
      });
    }
  }

  // OPTIMIZED: Faster first message
  Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
    if (me == null) {
      await getSelfInfo();
    }

    deductConnects(userForId: chatUser.id);

    final currentUserId = useCase.getUserId().toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // BATCH OPERATION for speed
    WriteBatch batch = firestore.batch();

    // Add mutual connection
    batch.set(
      firestore
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(chatUser.id),
      {'last_message_time': timestamp},
      SetOptions(merge: true),
    );

    batch.set(
      firestore
          .collection('Hamid_users')
          .doc(chatUser.id)
          .collection('my_users')
          .doc(currentUserId),
      {'last_message_time': timestamp},
      SetOptions(merge: true),
    );

    await batch.commit();
    await sendMessage(chatUser, msg, type);
  }

  // Block/Unblock methods remain the same
  static Future<void> blockUser(String userIdToBlock) async {
    try {
      await firestore
          .collection('Hamid_users')
          .doc(useCase.getUserId().toString())
          .update({
        'blockedUsers.$userIdToBlock': true,
      });

      await firestore.collection('Hamid_users').doc(userIdToBlock).update({
        'blockedUsers.${useCase.getUserId().toString()}': true,
      });

      log('User blocked successfully');
    } catch (e) {
      log('Error blocking user: $e');
    }
  }

  static Future<void> unblockUser(String userIdToUnblock) async {
    try {
      await firestore
          .collection('Hamid_users')
          .doc(useCase.getUserId().toString())
          .update({
        'blockedUsers.$userIdToUnblock': FieldValue.delete(),
      });

      await firestore.collection('Hamid_users').doc(userIdToUnblock).update({
        'blockedUsers.${useCase.getUserId().toString()}': FieldValue.delete(),
      });

      log('User unblocked successfully');
    } catch (e) {
      log('Error unblocking user: $e');
    }
  }

  static Future<bool> isUserBlocked(String userId) async {
    final userDoc = await firestore
        .collection('Hamid_users')
        .doc(useCase.getUserId().toString())
        .get();
    final blockedUsers = userDoc.data()?['blockedUsers'] ?? {};
    if (blockedUsers.isNotEmpty) {
      return blockedUsers.containsKey(userId);
    } else {
      return false;
    }
  }

  static Future<bool> isMyFriendBlocked(String userId) async {
    final userDoc = await firestore.collection('Hamid_users').doc(userId).get();
    final blockedUsers = userDoc.data()?['blockedUsers'] ?? {};
    return blockedUsers.containsKey(useCase.getUserId().toString());
  }

  deductConnects({required userForId}) async {
    final response = await systemUseCase.deductConnects(
      userForId: int.parse(userForId),
    );
    return response.fold(
          (error) {
        debugPrint(error.title);
      },
          (success) {
        debugPrint("deductConnects $success");
      },
    );
  }
}