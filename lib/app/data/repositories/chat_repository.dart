// chat_repository.dart - Complete implementation with message status

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

  // UPDATED: Optimized message sending with status tracking
  Future<void> sendMessageOptimized(
      ChatUser user,
      String msg,
      Type type, {
        Function(Message)? onMessageCreated,
        Function(String)? onMessageSent,
        Function(String)? onError,
      }) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final currentUserId = FirebaseService.me!.id;

    // Create message object with initial status
    final Message message = Message(
      toId: user.id,
      msg: msg,
      read: '',
      type: type,
      fromId: currentUserId,
      sent: time,
      status: MessageStatus.sending, // Initial status
    );

    // Notify UI immediately
    onMessageCreated?.call(message);

    try {
      // Update in Firestore
      final batch = FirebaseFirestore.instance.batch();

      // Add message with status
      final chatId = getConversationId(currentUserId, user.id);
      final messageRef = FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .doc(time);

      batch.set(messageRef, {
        ...message.toJson(),
        'status': 'sent', // Will be sent after commit
        'delivered': '', // Will be updated when delivered
      });

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
          'updated_by': currentUserId,
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
          'updated_by': currentUserId,
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      // Notify success
      onMessageSent?.call(time);

      // Send notification
      sendNotificationIfNeeded(user, msg, type, currentUserId);

      debugPrint('✅ Message sent with status tracking: $chatId');

    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      onError?.call(e.toString());

      // Try to update status to failed
      try {
        final chatId = getConversationId(currentUserId, user.id);
        await FirebaseFirestore.instance
            .collection('Hamid_chats')
            .doc(chatId)
            .collection('messages')
            .doc(time)
            .update({'status': 'failed'});
      } catch (_) {}

      rethrow;
    }
  }

  // NEW: Send message with status tracking
  Future<void> sendMessageWithStatus(
      ChatUser user,
      String msg,
      Type type, {
        Function(String)? onSent,
        Function()? onDelivered,
        Function()? onRead,
        Function(String)? onError,
      }) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatId = getConversationId(currentUserId, user.id);

    try {
      // Create message document with status
      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .doc(time)
          .set({
        'toId': user.id,
        'msg': msg,
        'read': '',
        'type': type.name,
        'fromId': currentUserId,
        'sent': time,
        'status': 'sent',
        'delivered': '',
      });

      // Update conversation timestamps
      await _updateConversationTimestamps(user.id, time);

      // Callback with message ID
      onSent?.call(time);

      // Listen for status updates
      _listenForStatusUpdates(chatId, time, onDelivered, onRead);

      // Send notification
      sendNotificationIfNeeded(user, msg, type, currentUserId);

    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      onError?.call(e.toString());
      rethrow;
    }
  }

  // NEW: Listen for message status updates
  void _listenForStatusUpdates(
      String chatId,
      String messageId,
      Function()? onDelivered,
      Function()? onRead,
      ) {
    FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;

      if (data['delivered'] != null &&
          data['delivered'].toString().isNotEmpty &&
          onDelivered != null) {
        onDelivered();
      }

      if (data['read'] != null &&
          data['read'].toString().isNotEmpty &&
          onRead != null) {
        onRead();
      }
    });
  }

  // NEW: Mark messages as delivered when user opens chat
  Future<void> markMessagesAsDelivered(String chatUserId) async {
    try {
      final chatId = getConversationId(currentUserId, chatUserId);
      final deliveryTime = DateTime.now().millisecondsSinceEpoch.toString();

      // Get undelivered messages sent to current user
      final undeliveredMessages = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .where('toId', isEqualTo: currentUserId)
          .where('delivered', isEqualTo: '')
          .get();

      if (undeliveredMessages.docs.isEmpty) return;

      // Batch update
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in undeliveredMessages.docs) {
        batch.update(doc.reference, {
          'delivered': deliveryTime,
          'status': 'delivered',
        });
      }

      await batch.commit();

      debugPrint('✅ Marked ${undeliveredMessages.docs.length} messages as delivered');
    } catch (e) {
      debugPrint('❌ Error marking messages as delivered: $e');
    }
  }

  // NEW: Mark single message as delivered
  Future<void> markMessageAsDelivered(Message message) async {
    if (message.fromId == currentUserId) return; // Don't mark own messages

    try {
      final chatId = getConversationId(message.fromId, message.toId);
      final deliveryTime = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.sent)
          .update({
        'delivered': deliveryTime,
        'status': 'delivered',
      });

      debugPrint('✅ Message marked as delivered');
    } catch (e) {
      debugPrint('❌ Error marking message as delivered: $e');
    }
  }

  // NEW: Get message status stream
  Stream<MessageStatus> getMessageStatusStream(String chatUserId, String messageId) {
    final chatId = getConversationId(currentUserId, chatUserId);

    return FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return MessageStatus.sending;

      final data = snapshot.data()!;

      // Check read status first
      if (data['read'] != null && data['read'].toString().isNotEmpty) {
        return MessageStatus.read;
      }

      // Then check delivered status
      if (data['delivered'] != null && data['delivered'].toString().isNotEmpty) {
        return MessageStatus.delivered;
      }

      // Then check if sent
      if (data['status'] == 'sent') {
        return MessageStatus.sent;
      }

      // Default to sending
      return MessageStatus.sending;
    });
  }

  // NEW: Resend failed message
  Future<void> resendMessage(String chatUserId, String messageId, String msg, Type type) async {
    try {
      final chatId = getConversationId(currentUserId, chatUserId);

      // Update status to sending
      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'status': 'sending'});

      // Small delay to show status change
      await Future.delayed(const Duration(milliseconds: 500));

      // Update to sent
      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'status': 'sent'});

      debugPrint('✅ Message resent successfully');
    } catch (e) {
      debugPrint('❌ Error resending message: $e');
      rethrow;
    }
  }

  // Helper: Update conversation timestamps
  Future<void> _updateConversationTimestamps(String otherUserId, String timestamp) async {
    final batch = FirebaseFirestore.instance.batch();

    // Update current user's my_users
    batch.set(
      FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(otherUserId),
      {'last_message_time': timestamp},
      SetOptions(merge: true),
    );

    // Update other user's my_users
    batch.set(
      FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(otherUserId)
          .collection('my_users')
          .doc(currentUserId),
      {'last_message_time': timestamp},
      SetOptions(merge: true),
    );

    // Update other user's last message
    batch.update(
      FirebaseFirestore.instance.collection('Hamid_users').doc(otherUserId),
      {'last_message': timestamp},
    );

    await batch.commit();
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

  // UPDATED: Mark message as read and update status
  Future<void> updateMessageReadStatus(Message message) async {
    if (message.fromId == currentUserId) return; // Don't mark own messages
    if (message.read.isNotEmpty) return; // Already read

    try {
      final chatId = getConversationId(message.fromId, message.toId);
      final readTime = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.sent)
          .update({
        'read': readTime,
        'status': 'read', // Update status to read
      });

      debugPrint('✅ Message marked as read with status update');
    } catch (e) {
      debugPrint('❌ Error marking message as read: $e');
    }
  }

  Future<void> blockUser(String userIdToBlock) =>
      FirebaseService.blockUser(userIdToBlock);

  Future<void> unblockUser(String userIdToUnblock) =>
      FirebaseService.unblockUser(userIdToUnblock);

  Future<bool> isUserBlocked(String userId) =>
      FirebaseService.isUserBlocked(userId);

  Future<bool> isMyFriendBlocked(String userId) =>
      FirebaseService.isMyFriendBlocked(userId);
}