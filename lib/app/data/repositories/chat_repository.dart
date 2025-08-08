import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/export.dart';
import '../../core/services/firebase_service/export.dart';
import '../../domain/export.dart';



class ChatRepository {
  String get currentUserId => Get.find<UserManagementUseCase>().getUserId().toString();

  Future<void> getSelfInfo() => FirebaseService.getSelfInfo();

  Future<ChatUser?> getUserById(String uid, String imageUrl) =>
      FirebaseService.getUserById(uid, imageUrl);
  // Add this helper method
  String getConversationId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) <= 0) {
      return '${userId1}_$userId2';
    } else {
      return '${userId2}_$userId1';
    }
  }
  Future<bool> userExists(String uid) => FirebaseService.userExists(uid);
  // Real-time listener for all chat updates
  Stream<List<Map<String, dynamic>>> getChatUpdatesStream(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('Hamid_chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
// Optimized message sending with immediate UI update
  Future<void> sendMessageOptimized(
      ChatUser user,
      String msg,
      Type type, {
        Function(Message)? onMessageCreated,
      }) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final currentUserId = FirebaseService.me!.id;

    // Create message object
    final Message message = Message(
      toId: user.id,
      msg: msg,
      read: '',
      type: type,
      fromId: currentUserId,
      sent: time,
    );

    // Notify UI immediately
    onMessageCreated?.call(message);

    // Update in Firestore
    final batch = FirebaseFirestore.instance.batch();

    // Add message
    // Add message to specific conversation only
    final chatId = getConversationId(currentUserId, user.id);
    final messageRef = FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(chatId)
        .collection('messages')
        .doc(time);

    batch.set(messageRef, message.toJson());

    // Update only the involved users' last message time
    // For sender (current user)
    batch.set(
      FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(user.id),
      {
        'last_message_time': time,
        'updated_by': currentUserId,  // Track who updated
      },
      SetOptions(merge: true),
    );

    // For receiver
    batch.set(
      FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(user.id)
          .collection('my_users')
          .doc(currentUserId),
      {
        'last_message_time': time,
        'updated_by': currentUserId,  // Track who updated
      },
      SetOptions(merge: true),
    );

    await batch.commit();
   await sendNotificationIfNeeded(user,  msg, type, currentUserId);
    debugPrint('✅ Message sent in isolated conversation: $chatId');
  }
  // Listen to real-time updates for a specific conversation
  Stream<DocumentSnapshot> getConversationMetadata(String chatId) {
    return FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(chatId)
        .snapshots();
  }

  Future<void> createUser({
    required String name,
    required String id,
    required String email,
    required String image,
    required bool isOnline,
    required bool isMobileOnline,
  }) =>
      FirebaseService.createUser(
        name: name,
        id: id,
        email: email,
        image: image,
        isOnline: isOnline,
        isMobileOnline: isMobileOnline,
      );

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(String currentUID) =>
      FirebaseService.getMyUsersId(currentUID);

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) =>
      FirebaseService.getAllUsers(userIds);

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(String uid) =>
      FirebaseService.getUserInfo(uid: uid);

  Future<bool> addChatUser(String uid) => FirebaseService.addChatUser(uid);

  Future<void> updateActiveStatus(bool isOnline) =>
      FirebaseService.updateActiveStatus(isOnline);

  Future<void> updateLastActive() => FirebaseService.updateLastActive();

  // Future<void> updateLastActiveOfReceiver(String receiverId) =>
  //     FirebaseService.updateLastActiveOfReceiver(receiverId);

  Future<void> insideChatStatus(bool isInside) =>
      FirebaseService.insideChatStatus(isInside);

  Future<void> updateFcmToken(String fcmToken) =>
      FirebaseService.updateFcmToken(fcmToken: fcmToken);

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) =>
      FirebaseService.getAllMessages(user);

  Future<void> sendMessage(ChatUser user, String msg, Type type) =>
      FirebaseService.sendMessage(user, msg, type);

  Future<void> sendNotificationIfNeeded(ChatUser user, String msg, Type type, String currentUserId) =>
      FirebaseService.sendNotificationIfNeeded(user, msg, type, currentUserId);

  Future<void> sendFirstMessage(ChatUser user, String msg, Type type) =>
      FirebaseService().sendFirstMessage(user, msg, type);

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) =>
      FirebaseService.getLastMessage(user);

  Future<void> sendChatImage(String currentUID, ChatUser user, File file) =>
      FirebaseService.sendChatImage(currentUID, user, file);

  Future<void> deleteMessage(Message message) =>
      FirebaseService.deleteMessage(message);

  Future<void> updateMessage(Message message, String updatedMsg) =>
      FirebaseService.updateMessage(message, updatedMsg);

  Future<void> updateMessageReadStatus(Message message) =>
      FirebaseService.updateMessageReadStatus(message);

  Future<void> blockUser(String userIdToBlock) =>
      FirebaseService.blockUser(userIdToBlock);

  Future<void> unblockUser(String userIdToUnblock) =>
      FirebaseService.unblockUser(userIdToUnblock);

  Future<bool> isUserBlocked(String userId) =>
      FirebaseService.isUserBlocked(userId);

  Future<bool> isMyFriendBlocked(String userId) =>
      FirebaseService.isMyFriendBlocked(userId);

}

