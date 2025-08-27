import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/export.dart';
import '../../core/services/firebase_service/export.dart';
import '../../domain/export.dart';

class ChatRepository {
  // Timer for debouncing typing updates
  Timer? _typingTimer;
  bool _isTyping = false;
  // Update typing status for current user
  Future<void> updateTypingStatus(String receiverId, bool isTyping) async {
    try {
      final currentUserId = Get.find<UserManagementUseCase>()
          .getUserId()
          .toString();
      final conversationId = getConversationId(currentUserId, receiverId);

      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .set({
        'typing_status': {
          currentUserId: {
            'is_typing': isTyping,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }
        }
      }, SetOptions(merge: true));

      debugPrint('🔤 Typing status updated: $isTyping');
    } catch (e) {
      debugPrint('❌ Error updating typing status: $e');
    }
  }

  // Stream to listen for typing status
  Stream<Map<String, dynamic>> getTypingStatusStream(String otherUserId) {
    final currentUserId = Get.find<UserManagementUseCase>()
        .getUserId()
        .toString();
    final conversationId = getConversationId(currentUserId, otherUserId);

    return FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final typingStatus = data['typing_status'] as Map<String, dynamic>? ?? {};

        // Check if other user is typing
        if (typingStatus.containsKey(otherUserId)) {
          final otherUserTyping = typingStatus[otherUserId] as Map<String, dynamic>;
          final isTyping = otherUserTyping['is_typing'] as bool? ?? false;
          final timestamp = otherUserTyping['timestamp'] as int? ?? 0;

          // Check if typing status is recent (within last 3 seconds)
          final now = DateTime.now().millisecondsSinceEpoch;
          final isRecent = (now - timestamp) < 3000;

          return {
            'is_typing': isTyping && isRecent,
            'user_id': otherUserId,
          };
        }
      }
      return {'is_typing': false, 'user_id': otherUserId};
    });
  }

  // Handle typing with debounce
  void handleTyping(String receiverId) {
    // Cancel previous timer
    _typingTimer?.cancel();

    // If not already typing, update status
    if (!_isTyping) {
      _isTyping = true;
      updateTypingStatus(receiverId, true);
    }

    // Set timer to stop typing after 2 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      updateTypingStatus(receiverId, false);
    });
  }

  // Stop typing immediately
  void stopTyping(String receiverId) {
    _typingTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      updateTypingStatus(receiverId, false);
    }
  }

  // Cleanup typing status on dispose
  void cleanupTypingStatus(String receiverId) {
    _typingTimer?.cancel();
    if (_isTyping) {
      updateTypingStatus(receiverId, false);
    }
  }

  String get currentUserId =>
      Get.find<UserManagementUseCase>().getUserId().toString();
  // Send message with status tracking
  Future<void> sendMessageWithStatus(
    ChatUser user,
    String msg,
    Type type, {
    Function(Message)? onMessageCreated,
    Function(MessageStatus)? onStatusUpdate,
  }) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final currentUserId = Get.find<UserManagementUseCase>()
        .getUserId()
        .toString();

    // Create message with pending status
    final Message message = Message(
      toId: user.id,
      msg: msg,
      read: '',
      type: type,
      fromId: currentUserId,
      sent: time,
      status: MessageStatus.pending,
    );

    // Notify UI immediately with pending status
    onMessageCreated?.call(message);
    onStatusUpdate?.call(MessageStatus.pending);

    try {
      final conversationId = getConversationId(currentUserId, user.id);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .collection('messages')
          .doc(time)
          .set({
            ...message.toJson(),
            'status': MessageStatus.sent.name,
            'delivered': '', // Empty until actually delivered
            'deliveryPending': true, // Track delivery pending status
          });

      // Update status to sent
      onStatusUpdate?.call(MessageStatus.sent);

      // Update timestamps
      await updateConversationTimestamps(currentUserId, user.id, time);
      // Set up real-time listener for delivery confirmation
      _listenForDeliveryConfirmation(
        conversationId: conversationId,
        messageId: time,
        onStatusUpdate: onStatusUpdate,
      );
      // Check if recipient is online to update delivery status
      // await checkAndUpdateDeliveryStatus(user.id, time, conversationId);
      await sendNotificationIfNeeded(user, msg, type, currentUserId);
    } catch (e) {
      // Update status to failed
      onStatusUpdate?.call(MessageStatus.failed);
      debugPrint('❌ Error sending message: $e');
      rethrow;
    }
  }
// Listen for delivery confirmation from recipient
  void _listenForDeliveryConfirmation({
    required String conversationId,
    required String messageId,
    Function(MessageStatus)? onStatusUpdate,
  }) {
    // Set up a listener for this specific message with timeout
    late StreamSubscription subscription;

    subscription = FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .snapshots()
        .timeout(const Duration(minutes: 5)) // Auto cleanup after 5 minutes
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final currentStatus = data['status'] as String?;

        // Check if message has been delivered
        if (data['delivered'] != null &&
            data['delivered'].toString().isNotEmpty &&
            currentStatus != 'delivered') {
          onStatusUpdate?.call(MessageStatus.delivered);
          debugPrint('✅ Message delivery confirmed via listener');
        }

        // Check if message has been read
        if (data['read'] != null &&
            data['read'].toString().isNotEmpty &&
            currentStatus != 'read') {
          onStatusUpdate?.call(MessageStatus.read);
          debugPrint('✅ Message read confirmed via listener');

          // Cancel subscription after message is read
          subscription.cancel();
        }
      }
    }, onError: (error) {
      debugPrint('❌ Error in delivery listener: $error');
      subscription.cancel();
    });

    // Auto cleanup after timeout
    Timer(const Duration(minutes: 5), () {
      subscription.cancel();
      debugPrint('🕐 Delivery listener auto-canceled after timeout');
    });
  }

// FIXED: Proper delivery confirmation method
  Future<void> confirmMessageDelivery(String senderId, String messageId) async {
    try {
      final currentUserId = Get.find<UserManagementUseCase>().getUserId().toString();
      final conversationId = getConversationId(currentUserId, senderId);
      final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

      // Get the message first to verify it exists and needs delivery confirmation
      final messageDoc = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        debugPrint('⚠️ Message not found for delivery confirmation: $messageId');
        return;
      }

      final messageData = messageDoc.data()!;

      // Verify this message is for the current user
      if (messageData['toId'] != currentUserId) {
        debugPrint('⚠️ Message not for current user, skipping delivery confirmation');
        return;
      }

      // Only update if not already delivered
      if (messageData['delivered'] == null ||
          messageData['delivered'].toString().isEmpty ||
          messageData['delivered'] == '') {

        await messageDoc.reference.update({
          'delivered': deliveredTime,
          'status': MessageStatus.delivered.name,
          'deliveryPending': false,
        });

        debugPrint('✅ Message delivery confirmed for: $messageId');
      } else {
        debugPrint('ℹ️ Message already delivered: $messageId');
      }
    } catch (e) {
      debugPrint('❌ Error confirming delivery: $e');
    }
  }

// FIXED: Better bulk delivery marking
  Future<void> markMessagesAsDelivered(String senderId) async {
    try {
      final currentUserId = Get.find<UserManagementUseCase>()
          .getUserId()
          .toString();
      final conversationId = getConversationId(currentUserId, senderId);

      // Get all undelivered messages from this sender
      final undeliveredMessages = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .collection('messages')
          .where('toId', isEqualTo: currentUserId)
          .where('fromId', isEqualTo: senderId)
          .where('delivered', isEqualTo: '')
          .orderBy('sent', descending: true)
          .limit(20) // Limit to recent messages for performance
          .get();

      if (undeliveredMessages.docs.isEmpty) {
        debugPrint('No undelivered messages to mark from $senderId');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

      for (var doc in undeliveredMessages.docs) {
        batch.update(doc.reference, {
          'delivered': deliveredTime,
          'status': MessageStatus.delivered.name,
          'deliveryPending': false,
        });
      }

      await batch.commit();
      debugPrint('✅ Marked ${undeliveredMessages.docs.length} messages as delivered from $senderId');
    } catch (e) {
      debugPrint('❌ Error marking messages as delivered: $e');
    }
  }

// FIXED: Enhanced message sending with better delivery tracking
//   Future<void> sendMessageWithStatus(
//       ChatUser user,
//       String msg,
//       Type type, {
//         Function(Message)? onMessageCreated,
//         Function(MessageStatus)? onStatusUpdate,
//       }) async {
//     final time = DateTime.now().millisecondsSinceEpoch.toString();
//     final currentUserId = Get.find<UserManagementUseCase>()
//         .getUserId()
//         .toString();
//
//     // Create message with pending status
//     final Message message = Message(
//       toId: user.id,
//       msg: msg,
//       read: '',
//       type: type,
//       fromId: currentUserId,
//       sent: time,
//       status: MessageStatus.pending,
//     );
//
//     // Notify UI immediately with pending status
//     onMessageCreated?.call(message);
//     onStatusUpdate?.call(MessageStatus.pending);
//
//     try {
//       final conversationId = getConversationId(currentUserId, user.id);
//
//       // Save to Firestore with proper delivery tracking
//       await FirebaseFirestore.instance
//           .collection('Hamid_chats')
//           .doc(conversationId)
//           .collection('messages')
//           .doc(time)
//           .set({
//         ...message.toJson(),
//         'status': MessageStatus.sent.name,
//         'delivered': '', // Empty until actually delivered
//         'deliveryPending': true, // Track delivery pending status
//         'timestamp': FieldValue.serverTimestamp(), // Server timestamp for ordering
//       });
//
//       // Update status to sent
//       onStatusUpdate?.call(MessageStatus.sent);
//
//       // Update timestamps
//       await updateConversationTimestamps(currentUserId, user.id, time);
//
//       // Set up delivery confirmation listener
//       _listenForDeliveryConfirmation(
//         conversationId: conversationId,
//         messageId: time,
//         onStatusUpdate: onStatusUpdate,
//       );
//
//       // Send notification with proper message data
//       await sendNotificationIfNeeded(user, msg, type, currentUserId, time);
//
//       debugPrint('✅ Message sent with delivery tracking setup');
//     } catch (e) {
//       // Update status to failed
//       onStatusUpdate?.call(MessageStatus.failed);
//       debugPrint('❌ Error sending message: $e');
//       rethrow;
//     }
//   }

  // Update conversation timestamps
  Future<void> updateConversationTimestamps(
    String userId1,
    String userId2,
    String timestamp,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    batch.set(
      FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId1)
          .collection('my_users')
          .doc(userId2),
      {'last_message_time': timestamp},
      SetOptions(merge: true),
    );

    batch.set(
      FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId2)
          .collection('my_users')
          .doc(userId1),
      {'last_message_time': timestamp},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

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
  // Add these methods to your ChatRepository class

  // Add reaction to message
  Future<void> addReactionToMessage(Message message, String reaction) async {
    final currentUserId = Get.find<UserManagementUseCase>()
        .getUserId()
        .toString();
    final conversationId = getConversationId(message.toId, message.fromId);

    try {
      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .collection('messages')
          .doc(message.sent)
          .update({'reactions.$currentUserId': reaction});

      debugPrint('✅ Reaction added successfully');
    } catch (e) {
      debugPrint('❌ Error adding reaction: $e');
      rethrow;
    }
  }

  // Remove reaction from message
  Future<void> removeReactionFromMessage(Message message) async {
    final currentUserId = Get.find<UserManagementUseCase>()
        .getUserId()
        .toString();
    final conversationId = getConversationId(message.toId, message.fromId);

    try {
      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .collection('messages')
          .doc(message.sent)
          .update({'reactions.$currentUserId': FieldValue.delete()});

      debugPrint('✅ Reaction removed successfully');
    } catch (e) {
      debugPrint('❌ Error removing reaction: $e');
      rethrow;
    }
  }

  // Send view-once image
  Future<void> sendViewOnceChatImage(
    String currentUID,
    ChatUser chatUser,
    File file,
  ) async {
    final ext = file.path.split('.').last;
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance.ref().child(
      'view_once_images/${FirebaseService.getConversationID(chatUser.id)}/$time.$ext',
    );

    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    final imageUrl = await ref.getDownloadURL();

    final Message message = Message(
      toId: chatUser.id,
      msg: imageUrl,
      read: '',
      type: Type.viewOnceImage,
      fromId: currentUID,
      sent: time,
      isViewOnce: true,
      isViewed: false,
    );

    // Save message to Firestore
    final conversationId = getConversationId(currentUID, chatUser.id);
    await FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .collection('messages')
        .doc(time)
        .set(message.toJson());

    // Update timestamps
    await FirebaseService.updateConversationTimestamp(
      currentUID,
      chatUser.id,
      time,
    );
    await FirebaseService.updateConversationTimestamp(
      chatUser.id,
      currentUID,
      time,
    );
  }

  // Mark view-once as viewedmarkViewOnceAsViewed
  Future<void> markViewOnceAsViewed(Message message) async {
    debugPrint('📸 Marking view-once as viewed: ${message.sent}');

    // First, delete the image from Firebase Storage
    // if (message.msg.startsWith('https://firebasestorage.googleapis.com')) {
    //   try {
    //     await FirebaseStorage.instance.refFromURL(message.msg).delete();
    //     debugPrint('✅ Image deleted from storage');
    //   } catch (e) {
    //     debugPrint('❌ Error deleting image from storage: $e');
    //   }
    // }
    final conversationId = getConversationId(message.toId, message.fromId);
    await FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .collection('messages')
        .doc(message.sent)
        .update({
          'isViewed': true,
          'msg': '📸 Photo was viewed', // Replace URL with text
          'type': Type.text.name,
          'viewedAt': DateTime.now().millisecondsSinceEpoch.toString(),
        });
  }

  // Delete view-once image from storage
  Future<void> deleteViewOnceImage(Message message) async {
    try {
      // Only delete if it's a view-once image with a valid URL
      if (message.type == Type.viewOnceImage &&
          message.msg.startsWith('https://firebasestorage.googleapis.com')) {
        await FirebaseStorage.instance.refFromURL(message.msg).delete();
        debugPrint('✅ Image deleted from storage');
      }
    } catch (e) {
      debugPrint(' ❌ Error deleting view-once image: $e');
    }
  }

  Future<bool> userExists(String uid) => FirebaseService.userExists(uid);
  // Real-time listener for all chat updates
  // Stream<List<Map<String, dynamic>>> getChatUpdatesStream(String currentUserId) {
  //   return FirebaseFirestore.instance
  //       .collection('Hamid_chats')
  //       .where('participants', arrayContains: currentUserId)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  // }
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
        'updated_by': currentUserId, // Track who updated
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
        'updated_by': currentUserId, // Track who updated
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    await sendNotificationIfNeeded(user, msg, type, currentUserId);
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
  }) => FirebaseService.createUser(
    name: name,
    id: id,
    email: email,
    image: image,
    isOnline: isOnline,
    isMobileOnline: isMobileOnline,
  );

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(String currentUID) =>
      FirebaseService.getMyUsersId(currentUID);

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
    List<String> userIds,
  ) => FirebaseService.getAllUsers(userIds);

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

  Future<void> sendNotificationIfNeeded(
    ChatUser user,
    String msg,
    Type type,
    String currentUserId,
      {String? messageTimestamp}
  ) => FirebaseService.sendNotificationIfNeeded(user, msg, type, currentUserId, messageTimestamp);

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
