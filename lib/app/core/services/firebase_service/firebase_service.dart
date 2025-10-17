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
  // Update the setAppState method to be more accurate
  static void setAppState({
    bool? isInForeground,
    bool? isInChat,
    String? chatUserId,
  }) {
    // Only update foreground state if explicitly provided
    if (isInForeground != null) {
      _isAppInForeground = isInForeground;
    }

    if (isInChat != null) {
      _isInChatScreen = isInChat;
    }

    if (chatUserId != null) {
      _currentChatUserId = chatUserId;
    } else if (isInChat == false) {
      // Clear chat user ID when exiting chat
      _currentChatUserId = null;
    }

    debugPrint(
      '📱 App State: Foreground=$_isAppInForeground, InChat=$_isInChatScreen, ChatUser=$_currentChatUserId',
    );
  }

  // for checking if user exist or not?
  static Future<bool> userExists(uid) async =>
      (await firestore.collection('Hamid_users').doc(uid).get()).exists;

  // OPTIMIZED: Faster chat connection
  static Future<bool> addChatUser(String uid) async {
    final data = await firestore
        .collection('Hamid_users')
        .where('id', isEqualTo: uid)
        .get();

    if (data.docs.isNotEmpty &&
        data.docs.first.id != useCase.getUserId().toString()) {
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
        {'last_message_time': timestamp, 'added_at': timestamp},
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
      return await firestore
          .collection('Hamid_users')
          .doc(id)
          .set(chatUser.toJson());
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
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
    List<String> userIds,
  ) {
    return firestore
        .collection('Hamid_users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  // stream for getting the user's Information
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo({
    required String uid,
  }) {
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

    debugPrint(
      '💬 Chat status updated: ${isInside ? "Inside chat" : "Outside chat"}',
    );
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

  // // stream for gell all the Messages
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
  //   return firestore
  //       .collection('Hamid_chats/${getConversationID(user.id)}/messages')
  //       .orderBy('sent', descending: true)
  //       .snapshots();
  // }
  // Updated Firebase Service methods to handle smart deletion

  // Modified getAllMessages to filter out deleted messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    final currentUserId = useCase.getUserId().toString();

    return firestore
        .collection('Hamid_chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // Check if this chat was deleted by current user
          final deletionDoc = await firestore
              .collection('Hamid_users')
              .doc(currentUserId)
              .collection('deleted_chats')
              .doc(user.id)
              .get();

          if (!deletionDoc.exists) {
            // Chat was never deleted, return all messages
            return snapshot;
          }

          // Get deletion timestamp
          final deletionTime = deletionDoc.data()!['deleted_at'] as String;
          final deletionTimestamp = int.parse(deletionTime);

          // Filter messages - only show messages sent after deletion
          final filteredDocs = snapshot.docs.where((doc) {
            final messageSentTime = doc.data()['sent'] as String;
            final messageTimestamp = int.parse(messageSentTime);
            return messageTimestamp > deletionTimestamp;
          }).toList();

          // Create a new QuerySnapshot with filtered documents
          return _createFilteredSnapshot(snapshot, filteredDocs);
        });
  }

  // Modified getLastMessage to respect deletion time
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser user,
  ) {
    return firestore
        .collection('Hamid_chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return snapshot;

          // Check if this message should be shown
          final currentUserId = useCase.getUserId().toString();
          final deletionDoc = await firestore
              .collection('Hamid_users')
              .doc(currentUserId)
              .collection('deleted_chats')
              .doc(user.id)
              .get();

          if (!deletionDoc.exists) {
            return snapshot; // No deletion record, show message
          }

          final deletionTime = int.parse(
            deletionDoc.data()!['deleted_at'] as String,
          );
          final messageTime = int.parse(
            snapshot.docs.first.data()['sent'] as String,
          );

          if (messageTime > deletionTime) {
            return snapshot; // Message is newer than deletion, show it
          } else {
            // Message is older than deletion, return empty
            return _createEmptySnapshot();
          }
        });
  }

  // Modified sendMessage to handle re-connection after deletion
  //   static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
  //     if (me == null) {
  //       await getSelfInfo();
  //     }
  //
  //     final time = DateTime.now().millisecondsSinceEpoch.toString();
  //     final currentUserId = useCase.getUserId().toString();
  //
  //     // Check if chat was deleted by current user
  //     final deletionDoc = await firestore
  //         .collection('Hamid_users')
  //         .doc(currentUserId)
  //         .collection('deleted_chats')
  //         .doc(chatUser.id)
  //         .get();
  //
  //     final Message message = Message(
  //       toId: chatUser.id,
  //       msg: msg,
  //       read: '',
  //       type: type,
  //       fromId: currentUserId,
  //       sent: time,
  //     );
  //
  //     try {
  //       // If chat was deleted by current user, restore connection
  //       if (deletionDoc.exists) {
  //         debugPrint('🔄 Restoring deleted chat connection...');
  //
  //         // Remove deletion record
  //         await firestore
  //             .collection('Hamid_users')
  //             .doc(currentUserId)
  //             .collection('deleted_chats')
  //             .doc(chatUser.id)
  //             .delete();
  //
  //         // Re-add to my_users
  //         await firestore
  //             .collection('Hamid_users')
  //             .doc(currentUserId)
  //             .collection('my_users')
  //             .doc(chatUser.id)
  //             .set({'last_message_time': time});
  //       }
  //
  //       // PARALLEL OPERATIONS for speed
  //       await Future.wait([
  //         // 1. Save message
  //         firestore
  //             .collection('Hamid_chats/${getConversationID(chatUser.id)}/messages')
  //             .doc(time)
  //             .set(message.toJson()),
  //
  //         // 2. Update timestamps
  //         updateConversationTimestamp(currentUserId, chatUser.id, time),
  //         updateConversationTimestamp(chatUser.id, currentUserId, time),
  //
  //         // 3. Update receiver's last message
  //         firestore.collection('Hamid_users').doc(chatUser.id).update({
  //           'last_message': time,
  //         }),
  //       ]);
  //
  //       debugPrint('✅ Message sent successfully');
  //
  //       // 4. Send notification ONLY if needed (non-blocking)
  //       sendNotificationIfNeeded(chatUser, msg, type, currentUserId);
  //
  //     } catch (e) {
  //       debugPrint('❌ Error sending message: $e');
  //     }
  //   }

  // Helper method to create filtered snapshot
  static QuerySnapshot<Map<String, dynamic>> _createFilteredSnapshot(
    QuerySnapshot<Map<String, dynamic>> originalSnapshot,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredDocs,
  ) {
    // Return a custom filtered snapshot
    return FilteredQuerySnapshot(
      docs: filteredDocs,
      metadata: originalSnapshot.metadata,
    );
  }

  // Helper method to create empty snapshot
  static QuerySnapshot<Map<String, dynamic>> _createEmptySnapshot() {
    // Return empty snapshot - implement based on your Firebase version
    throw UnimplementedError('Implement based on your Firebase setup');
  }

  // Method to restore chat when receiving new message
  static Future<void> restoreChatIfDeleted(String senderId) async {
    try {
      final currentUserId = useCase.getUserId().toString();
      final deletionDoc = await firestore
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('deleted_chats')
          .doc(senderId)
          .get();

      if (deletionDoc.exists) {
        debugPrint('🔄 Auto-restoring chat from $senderId');

        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        // Remove deletion record and restore connection
        WriteBatch batch = firestore.batch();

        batch.delete(
          firestore
              .collection('Hamid_users')
              .doc(currentUserId)
              .collection('deleted_chats')
              .doc(senderId),
        );

        batch.set(
          firestore
              .collection('Hamid_users')
              .doc(currentUserId)
              .collection('my_users')
              .doc(senderId),
          {'last_message_time': timestamp},
        );

        await batch.commit();
        debugPrint('✅ Chat restored automatically');
      }
    } catch (e) {
      debugPrint('❌ Error restoring chat: $e');
    }
  }
  // Add these methods to your Firebase Service
  // These will filter messages to show only new ones after deletion

  // Modified getAllMessages to filter deleted messages
  static Stream<List<Message>> getAllMessagesFiltered(ChatUser user) async* {
    final currentUserId = useCase.getUserId().toString();

    // Get deletion timestamp first
    String? deletionTime = await _getDeletionTime(currentUserId, user.id);

    await for (final snapshot
        in firestore
            .collection('Hamid_chats/${getConversationID(user.id)}/messages')
            .orderBy('sent', descending: true)
            .snapshots()) {
      List<Message> filteredMessages = [];

      for (var doc in snapshot.docs) {
        try {
          final message = Message.fromJson(doc.data());

          // If no deletion time, show all messages
          if (deletionTime == null) {
            filteredMessages.add(message);
            continue;
          }

          // Only show messages sent after deletion
          final messageTimestamp = int.parse(message.sent);
          final deletionTimestamp = int.parse(deletionTime);

          if (messageTimestamp > deletionTimestamp) {
            filteredMessages.add(message);
          }
        } catch (e) {
          debugPrint('❌ Error parsing message: $e');
        }
      }

      yield filteredMessages;
    }
  }

  // Helper method to get deletion time
  static Future<String?> _getDeletionTime(
    String userId,
    String chatUserId,
  ) async {
    try {
      final userDoc = await firestore
          .collection('Hamid_users')
          .doc(userId)
          .get();
      final deletedChats =
          userDoc.data()?['deleted_chats'] as Map<String, dynamic>? ?? {};
      return deletedChats[chatUserId] as String?;
    } catch (e) {
      debugPrint('❌ Error getting deletion time: $e');
      return null;
    }
  }

  // Modified getLastMessage to respect deletion time
  static Stream<Message?> getLastMessageFiltered(ChatUser user) async* {
    final currentUserId = useCase.getUserId().toString();

    await for (final snapshot
        in firestore
            .collection('Hamid_chats/${getConversationID(user.id)}/messages')
            .orderBy('sent', descending: true)
            .limit(1)
            .snapshots()) {
      if (snapshot.docs.isEmpty) {
        yield null;
        continue;
      }

      try {
        final message = Message.fromJson(snapshot.docs.first.data());

        // Check if this message should be shown
        String? deletionTime = await _getDeletionTime(currentUserId, user.id);

        if (deletionTime == null) {
          yield message; // No deletion, show message
          continue;
        }

        final messageTimestamp = int.parse(message.sent);
        final deletionTimestamp = int.parse(deletionTime);

        if (messageTimestamp > deletionTimestamp) {
          yield message; // Message is newer than deletion
        } else {
          yield null; // Message is older than deletion
        }
      } catch (e) {
        debugPrint('❌ Error parsing last message: $e');
        yield null;
      }
    }
  }

  // Updated ensureMutualChatConnection with better logic
  static Future<void> ensureMutualChatConnection(
    String senderId,
    String receiverId,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Check if receiver had deleted this chat
      final receiverDoc = await firestore
          .collection('Hamid_users')
          .doc(receiverId)
          .get();
      final receiverData = receiverDoc.data() ?? {};
      final deletedChats =
          receiverData['deleted_chats'] as Map<String, dynamic>? ?? {};

      WriteBatch batch = firestore.batch();

      // Always ensure sender has the connection
      batch.set(
        firestore
            .collection('Hamid_users')
            .doc(senderId)
            .collection('my_users')
            .doc(receiverId),
        {'last_message_time': timestamp},
        SetOptions(merge: true),
      );

      // If receiver had deleted this chat, restore it
      if (deletedChats.containsKey(senderId)) {
        debugPrint('🔄 Auto-restoring deleted chat for receiver');

        // Add back to receiver's my_users
        batch.set(
          firestore
              .collection('Hamid_users')
              .doc(receiverId)
              .collection('my_users')
              .doc(senderId),
          {'last_message_time': timestamp},
          SetOptions(merge: true),
        );

        // IMPORTANT: Don't remove deletion timestamp yet
        // Keep it so that old messages remain filtered
        // Only remove it when receiver manually starts chatting
      } else {
        // Normal case - just update timestamp
        batch.set(
          firestore
              .collection('Hamid_users')
              .doc(receiverId)
              .collection('my_users')
              .doc(senderId),
          {'last_message_time': timestamp},
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      debugPrint('✅ Mutual connection ensured');
    } catch (e) {
      debugPrint('❌ Error in mutual connection: $e');
    }
  }

  // Call this method when user actively starts chatting (clears deletion filter)
  static Future<void> clearDeletionFilter(String chatUserId) async {
    try {
      final currentUserId = useCase.getUserId().toString();

      await firestore.collection('Hamid_users').doc(currentUserId).update({
        'deleted_chats.$chatUserId': FieldValue.delete(),
      });

      debugPrint('✅ Deletion filter cleared for $chatUserId');
    } catch (e) {
      debugPrint('❌ Error clearing deletion filter: $e');
    }
  }
  // Updated sendMessage in firebase_service.dart to handle re-connection
  // When user sends a message after deleting chat, it should restore the chat

  // Update sendMessage to NOT remove deletion record immediately
  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg,
    Type type,
  ) async {
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
      // Check if chat was deleted
      final deletionDoc = await firestore
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('deleted_chats')
          .doc(chatUser.id)
          .get();

      if (deletionDoc.exists) {
        debugPrint('🔄 Sending message to previously deleted chat...');

        // DON'T remove deletion record - keep it for filtering old messages
        // Just restore the chat in my_users
        await firestore
            .collection('Hamid_users')
            .doc(currentUserId)
            .collection('my_users')
            .doc(chatUser.id)
            .set({'last_message_time': time});
      }

      // Send the message
      await firestore
          .collection('Hamid_chats/${getConversationID(chatUser.id)}/messages')
          .doc(time)
          .set(message.toJson());

      // Update timestamps
      await updateConversationTimestamp(currentUserId, chatUser.id, time);

      // Only update receiver's timestamp if they have the chat
      final receiverChatDoc = await firestore
          .collection('Hamid_users')
          .doc(chatUser.id)
          .collection('my_users')
          .doc(currentUserId)
          .get();

      if (receiverChatDoc.exists) {
        await updateConversationTimestamp(chatUser.id, currentUserId, time);
      }

      // Update receiver's last message
      await firestore.collection('Hamid_users').doc(chatUser.id).update({
        'last_message': time,
      });

      debugPrint('✅ Message sent successfully');
      sendNotificationIfNeeded(chatUser, msg, type, currentUserId, time);
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
    }
  }

  // Add method to permanently clear deletion record (optional)
  // Call this when user explicitly wants to see old messages again
  //   Future<void> _clearChatDeletion(String userId) async {
  //     try {
  //       await FirebaseFirestore.instance
  //           .collection('Hamid_users')
  //           .doc(currentUserId)
  //           .collection('deleted_chats')
  //           .doc(userId)
  //           .delete();
  //
  //       debugPrint('✅ Chat deletion record cleared - all messages visible now');
  //     } catch (e) {
  //       debugPrint('❌ Error clearing deletion record: $e');
  //     }
  //   }
  // Updated sendFirstMessage with optional timestamp parameter
   static Future<void> sendFirstMessage(
    ChatUser chatUser,
    String msg,
    Type type, {
    String? messageId,  // Optional message ID to use
  }) async {
    if (me == null) {
      await getSelfInfo();
    }

    final currentUserId = useCase.getUserId().toString();
    final timestamp = messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

    WriteBatch batch = firestore.batch();

    // Add to current user's my_users
    batch.set(
      firestore
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(chatUser.id),
      {'last_message_time': timestamp},
      SetOptions(merge: true),
    );

    // Check if receiver has deleted this chat
    final receiverDeletionDoc = await firestore
        .collection('Hamid_users')
        .doc(chatUser.id)
        .collection('deleted_chats')
        .doc(currentUserId)
        .get();

    // Only add to receiver's my_users if they haven't deleted the chat
    if (!receiverDeletionDoc.exists) {
      batch.set(
        firestore
            .collection('Hamid_users')
            .doc(chatUser.id)
            .collection('my_users')
            .doc(currentUserId),
        {'last_message_time': timestamp},
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    
    // Send message with the same timestamp/messageId
    await sendMessageWithId(chatUser, msg, type, messageId: timestamp, isFirstMessage: true, recipientId: chatUser.id);
  }
  
  // New method to send message with specific ID
  static Future<void> sendMessageWithId(
    ChatUser chatUser,
    String msg,
    Type type, {
    required String messageId,
    bool isFirstMessage = false,
    String? recipientId,
  }) async {
    if (me == null) {
      await getSelfInfo();
    }

    final currentUserId = useCase.getUserId().toString();

    final Message message = Message(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      fromId: currentUserId,
      sent: messageId,
      status: MessageStatus.sent, // Set as sent initially
    );

    try {
      // Send the message with specific ID
      await firestore
          .collection('Hamid_chats/${getConversationID(chatUser.id)}/messages')
          .doc(messageId)
          .set(message.toJson());

      // Update timestamps
      await updateConversationTimestamp(currentUserId, chatUser.id, messageId);

      // Only update receiver's timestamp if they have the chat
      final receiverChatDoc = await firestore
          .collection('Hamid_users')
          .doc(chatUser.id)
          .collection('my_users')
          .doc(currentUserId)
          .get();

      if (receiverChatDoc.exists) {
        await updateConversationTimestamp(chatUser.id, currentUserId, messageId);
      }

      // Update receiver's last message
      await firestore.collection('Hamid_users').doc(chatUser.id).update({
        'last_message': messageId,
      });

      debugPrint('✅ Message sent with ID: $messageId');
      
      // If this is the first message, deduct connects only after successful send
      if (isFirstMessage && recipientId != null) {
        await deductConnects(userForId: recipientId);
        debugPrint('✅ Connects deducted after first message sent successfully');
      }
      
      sendNotificationIfNeeded(chatUser, msg, type, currentUserId, messageId);

    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      // If it's first message and it failed, don't deduct connects
      if (isFirstMessage) {
        debugPrint('⚠️ First message failed - connects not deducted');
      }
      rethrow; // Rethrow to handle in calling code
    }
  }

  // Add this method to handle incoming messages
  // When receiving a message from a deleted chat, optionally restore it

  // static Future<void> handleIncomingMessage(String senderId) async {
  //   try {
  //     final currentUserId = useCase.getUserId().toString();
  //
  //     // Check if current user has this chat
  //     final chatDoc = await firestore
  //         .collection('Hamid_users')
  //         .doc(currentUserId)
  //         .collection('my_users')
  //         .doc(senderId)
  //         .get();
  //
  //     if (!chatDoc.exists) {
  //       // Check if it was deleted
  //       final deletionDoc = await firestore
  //           .collection('Hamid_users')
  //           .doc(currentUserId)
  //           .collection('deleted_chats')
  //           .doc(senderId)
  //           .get();
  //
  //       if (deletionDoc.exists) {
  //         debugPrint('📨 New message from deleted chat. Auto-restoring...');
  //
  //         final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //         // Remove deletion record
  //         await deletionDoc.reference.delete();
  //
  //         // Restore to my_users
  //         await firestore
  //             .collection('Hamid_users')
  //             .doc(currentUserId)
  //             .collection('my_users')
  //             .doc(senderId)
  //             .set({'last_message_time': timestamp});
  //
  //         debugPrint('✅ Chat restored due to new message');
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Error handling incoming message: $e');
  //   }
  // }
  static Future<void> updateConversationTimestamp(
    String userId,
    String otherUserId,
    String timestamp,
  ) async {
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
  // static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
  //   if (me == null) {
  //     await getSelfInfo();
  //   }
  //
  //   final time = DateTime.now().millisecondsSinceEpoch.toString();
  //   final currentUserId = useCase.getUserId().toString();
  //
  //   final Message message = Message(
  //     toId: chatUser.id,
  //     msg: msg,
  //     read: '',
  //     type: type,
  //     fromId: currentUserId,
  //     sent: time,
  //   );
  //
  //   try {
  //     // PARALLEL OPERATIONS for speed
  //     await Future.wait([
  //       // 1. Save message
  //       firestore
  //           .collection('Hamid_chats/${getConversationID(chatUser.id)}/messages')
  //           .doc(time)
  //           .set(message.toJson()),
  //
  //       // 2. Update timestamps
  //       updateConversationTimestamp(currentUserId, chatUser.id, time),
  //       updateConversationTimestamp(chatUser.id, currentUserId, time),
  //
  //       // 3. Update receiver's last message
  //       firestore.collection('Hamid_users').doc(chatUser.id).update({
  //         'last_message': time,
  //       }),
  //     ]);
  //
  //     debugPrint('✅ Message sent successfully');
  //
  //     // 4. Send notification ONLY if needed (non-blocking)
  //     sendNotificationIfNeeded(chatUser, msg, type, currentUserId);
  //
  //   } catch (e) {
  //     debugPrint('❌ Error sending message: $e');
  //   }
  // }

  // OPTIMIZED: Smart notification sending
  static Future<void> sendNotificationIfNeeded(
    ChatUser chatUser,
    String msg,
    Type type,
    String currentUserId,
      String messageTimestamp
  ) async {
    try {
      final userDoc = await firestore
          .collection('Hamid_users')
          .doc(chatUser.id)
          .get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final isReceiverOnline = userData['is_online'] as bool? ?? false;
      final isReceiverInChat = userData['is_inside'] as bool? ?? false;
      final fcmToken = userData['push_token'] as String? ?? '';

      // SMART NOTIFICATION LOGIC
      bool shouldSendNotification =
          fcmToken.isNotEmpty &&
          (!isReceiverOnline || // User is offline
              !isReceiverInChat || // User is online but not in chat
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
            messageTimestamp: messageTimestamp,
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
      final conversationId = getConversationID(message.fromId);
      final readTime = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .collection('messages')
          .doc(message.sent)
          .update({'read': readTime, 'status': MessageStatus.read.name});

      debugPrint('✅ Message read status updated in Firestore');
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        debugPrint('Document not found: ${message.sent}');
      } else {
        rethrow;
      }
    }
  }

  // // stream for getting the last message
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
  //   return firestore
  //       .collection('Hamid_chats/${getConversationID(user.id)}/messages')
  //       .orderBy('sent', descending: true)
  //       .limit(1)
  //       .snapshots();
  // }

  // for sending images in chats
  static Future<void> sendChatImage(
    String currentUID,
    ChatUser chatUser,
    File file,
  ) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
      'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then(
          (p0) => log('data transfered: ${p0.bytesTransferred / 1000} kbs'),
        );

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
  // Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
  //   if (me == null) {
  //     await getSelfInfo();
  //   }
  //
  //   deductConnects(userForId: chatUser.id);
  //
  //   final currentUserId = useCase.getUserId().toString();
  //   final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //   // BATCH OPERATION for speed
  //   WriteBatch batch = firestore.batch();
  //
  //   // Add mutual connection
  //   batch.set(
  //     firestore
  //         .collection('Hamid_users')
  //         .doc(currentUserId)
  //         .collection('my_users')
  //         .doc(chatUser.id),
  //     {'last_message_time': timestamp},
  //     SetOptions(merge: true),
  //   );
  //
  //   batch.set(
  //     firestore
  //         .collection('Hamid_users')
  //         .doc(chatUser.id)
  //         .collection('my_users')
  //         .doc(currentUserId),
  //     {'last_message_time': timestamp},
  //     SetOptions(merge: true),
  //   );
  //
  //   await batch.commit();
  //   await sendMessage(chatUser, msg, type);
  // }

  // Block/Unblock methods remain the same
  static Future<void> blockUser(String userIdToBlock) async {
    try {
      final _ = useCase.getUserId().toString();

      await firestore
          .collection('Hamid_users')
          .doc(useCase.getUserId().toString())
          .update({
            'blockedUsers.$userIdToBlock': FieldValue.serverTimestamp(),
          });

      // await firestore.collection('Hamid_users').doc(userIdToBlock).update({
      //   'blockedUsers.${useCase.getUserId().toString()}': true,
      // });

      debugPrint('✅ User $userIdToBlock blocked successfully');
    } catch (e) {
      debugPrint('❌ Error blocking user: $e');
    }
  }

  static Future<void> unblockUser(String userIdToUnblock) async {
    try {
      final currentUserId = useCase.getUserId().toString();
      await firestore
          .collection('Hamid_users')
          .doc(useCase.getUserId().toString())
          .update({'blockedUsers.$userIdToUnblock': FieldValue.delete()});

      // DO NOT update the other user's blockedUsers
      // Remove this part:
      // await firestore.collection('Hamid_users').doc(userIdToUnblock).update({
      //   'blockedUsers.${useCase.getUserId().toString()}': FieldValue.delete(),
      // });

      debugPrint('✅ User $userIdToUnblock unblocked successfully');
    } catch (e) {
      debugPrint('❌ Error unblocking user: $e');
    }
  }

  static Future<bool> isUserBlocked(String userId) async {
    final currentUserId = useCase.getUserId().toString();

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

  // FIXED: Check if current user is blocked by someone
  static Future<bool> isBlockedByUser(String userId) async {
    try {
      final currentUserId = useCase.getUserId().toString();
      final otherUserDoc = await firestore
          .collection('Hamid_users')
          .doc(userId)
          .get();

      final blockedUsers = otherUserDoc.data()?['blockedUsers'] ?? {};
      return blockedUsers.containsKey(currentUserId);
    } catch (e) {
      log('Error checking if blocked by user: $e');
      return false;
    }
  }

  // DEPRECATED: Use isBlockedByUser instead
  static Future<bool> isMyFriendBlocked(String userId) async {
    return isBlockedByUser(userId);
  }
  // static Future<bool> isMyFriendBlocked(String userId) async {
  //   final userDoc = await firestore.collection('Hamid_users').doc(userId).get();
  //   final blockedUsers = userDoc.data()?['blockedUsers'] ?? {};
  //   return blockedUsers.containsKey(useCase.getUserId().toString());
  // }

  static deductConnects({required userForId}) async {
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

// Custom QuerySnapshot implementation for filtered results
class FilteredQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  @override
  final SnapshotMetadata metadata;

  FilteredQuerySnapshot({required this.docs, required this.metadata});

  @override
  List<DocumentChange<Map<String, dynamic>>> get docChanges => [];

  @override
  int get size => docs.length;
}
