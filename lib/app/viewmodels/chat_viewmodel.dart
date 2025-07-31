// chat_viewmodel.dart - Fixed for proper navigation and state management

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/export.dart';
import '../core/services/firebase_service/export.dart';
import '../data/repositories/chat_repository.dart';
import 'dart:io';

import '../views/chat/export.dart';
import 'chat_list_viewmodel.dart';

class ChatViewModel extends GetxController {
  // Cache for storing messages by conversation ID
   final Map<String, List<Message>> _messageCache = {};
  static final Map<String, StreamSubscription> _activeStreams = {};

  final ChatRepository _repo = ChatRepository();
  String? get currentChatUserId => selectedUser.value?.id;
  var chatUsers = <ChatUser>[].obs;
  var messages = <Message>[].obs;
  var selectedUser = Rxn<ChatUser>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  // Deletion tracking
  final RxnString currentChatDeletionTime = RxnString();


  // FIXED: Better navigation state management
  String? pendingChatUserId;
  ChatUser? notificationUser;
  bool _isNavigatingFromNotification = false;
  bool _hasHandledNotification = false;

  final RxBool isFromNotification = false.obs;
  // final Map<String, List<Message>> _messageCache = {};
  // Add method to check if chatting with specific user

  List<Message>? getCachedMessages(String userId) {
    return _messageCache[userId];
  }

  // Get filtered message stream
  Stream<List<Message>> getFilteredMessagesStream(ChatUser user) {
    selectedUser.value = user;
    setInsideChatStatus(true, chatUserId: user.id);

    // Check deletion record first
    checkDeletionRecord();

    return _repo.getAllMessages(user).map((snapshot) {
      final allMessages = snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();

      // Filter messages if chat was deleted
      final filteredMessages = filterMessages(allMessages);

      // Update reactive list
      messages.assignAll(filteredMessages);

      // Cache messages
      if (filteredMessages.isNotEmpty) {
        _messageCache[user.id] = filteredMessages;
      }

      return filteredMessages;
    });
  }
  // Clear deletion record (optional - for "show all messages" feature)
  Future<void> clearDeletionRecord() async {
    if (selectedUser.value == null) return;

    final listController = Get.find<ChatListController>();
    await listController.clearDeletionRecord(selectedUser.value!.id);

    currentChatDeletionTime.value = null;

    // Refresh messages
    messages.refresh();
  }

  // Filter messages based on deletion time
  List<Message> filterMessages(List<Message> allMessages) {
    if (currentChatDeletionTime.value == null) {
      return allMessages;
    }

    final deletionTimestamp = int.parse(currentChatDeletionTime.value!);
    return allMessages.where((message) {
      final messageTimestamp = int.parse(message.sent);
      return messageTimestamp > deletionTimestamp;
    }).toList();
  }

  void cacheMessages(String userId, List<Message> messages) {
    _messageCache[userId] = messages;
  }
  void setNavigationSource({required bool fromNotification}) {
    isFromNotification.value = fromNotification;
  }/// FIXED: Proper notification navigation handling
  Future<void> handlePendingNavigation() async {
    // PREVENT: Multiple navigation attempts
    if (_isNavigatingFromNotification || _hasHandledNotification) {
      debugPrint('🚫 Navigation already in progress or handled');
      return;
    }

    debugPrint('🔄 Checking for notification navigation...');

    // Check for direct notification user first
    if (notificationUser != null) {
      debugPrint('📱 Found notification user: ${notificationUser!.name}');

      _isNavigatingFromNotification = true;
      final userToNavigate = notificationUser!;

      // Clear notification data immediately
      notificationUser = null;
      _hasHandledNotification = true;

      // FIXED: Only navigate if app is in foreground and user wants to
      if (await _shouldNavigateToChat()) {
        await Future.delayed(const Duration(milliseconds: 500));

        debugPrint('🚀 Navigating to chat from notification...');
        Get.to(() => ChattingView(user: userToNavigate));
        debugPrint('✅ Navigation successful from notification');
      } else {
        debugPrint('🚫 Navigation cancelled - app not ready or user declined');
      }

      _isNavigatingFromNotification = false;
      return;
    }

    // Fallback to pendingChatUserId approach
    if (pendingChatUserId != null && pendingChatUserId!.isNotEmpty) {
      debugPrint('📲 Processing pending chat user ID: $pendingChatUserId');

      _isNavigatingFromNotification = true;

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(pendingChatUserId!)
            .get();

        if (userDoc.exists) {
          final chatUser = ChatUser.fromJson(userDoc.data()!);
          debugPrint('✅ Found user from Firestore: ${chatUser.name}');

          // Clear pending data
          pendingChatUserId = null;
          _hasHandledNotification = true;

          if (await _shouldNavigateToChat()) {
            await Future.delayed(const Duration(milliseconds: 500));
            Get.to(() => ChattingView(user: chatUser));
            debugPrint('✅ Navigation successful from Firestore');
          } else {
            debugPrint('🚫 Navigation cancelled');
          }
        } else {
          debugPrint('❌ User not found in Firestore');
          pendingChatUserId = null;
        }
      } catch (e) {
        debugPrint('💥 Error fetching user: $e');
        pendingChatUserId = null;
      }

      _isNavigatingFromNotification = false;
    } else {
      debugPrint('ℹ️ No pending navigation found');
    }
  }

  /// FIXED: Smart navigation decision
  Future<bool> _shouldNavigateToChat() async {
    try {
      // Check if app is in foreground
      final isAppActive = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

      if (!isAppActive) {
        debugPrint('📱 App not active, skipping navigation');
        return false;
      }

      // OPTIONAL: Show confirmation dialog
      bool? userWantsToNavigate = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Open Chat'),
          content: const Text('You have a new message. Open chat?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Open'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      return userWantsToNavigate ?? false;
    } catch (e) {
      debugPrint('❌ Error in navigation decision: $e');
      return false;
    }
  }

  /// FIXED: Reset navigation state
  void resetNotificationState() {
    _hasHandledNotification = false;
    _isNavigatingFromNotification = false;
    notificationUser = null;
    pendingChatUserId = null;
    debugPrint('🔄 Notification state reset');
  }
  // Check and load deletion record for current chat
  Future<void> checkDeletionRecord() async {
    if (selectedUser.value == null) return;

    try {
      final deletionDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_repo.currentUserId)
          .collection('deleted_chats')
          .doc(selectedUser.value!.id)
          .get();

      if (deletionDoc.exists) {
        currentChatDeletionTime.value = deletionDoc.data()!['deleted_at'] as String;
        debugPrint('📌 Found deletion record: ${currentChatDeletionTime.value}');
      } else {
        currentChatDeletionTime.value = null;
      }
    } catch (e) {
      debugPrint('❌ Error checking deletion record: $e');
      currentChatDeletionTime.value = null;
    }
  }

  Future<String> getActualLastMessageTime(String otherUserId) async {
    try {
      final currentUserId = _repo.currentUserId;
      final chatId = getConversationId(currentUserId, otherUserId);

      final lastMessage = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('sent', descending: true)
          .limit(1)
          .get();

      if (lastMessage.docs.isNotEmpty) {
        return lastMessage.docs.first.data()['sent'] ?? '0';
      }

      return '0';
    } catch (e) {
      debugPrint('Error getting last message time: $e');
      return '0';
    }
  }

  Future<void> migrateToConversationTimestamps() async {
    try {
      final chatViewModel = Get.find<ChatViewModel>();
      chatViewModel.setNavigationSource(fromNotification: true);
      debugPrint('🔄 Starting migration...');

      final currentUserId = _repo.currentUserId;
      final myUsersSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(currentUserId)
          .collection('my_users')
          .get();

      for (var userDoc in myUsersSnapshot.docs) {
        final otherUserId = userDoc.id;
        final data = userDoc.data();

        if (data['last_message_time'] == null) {
          final chatId = getConversationId(currentUserId, otherUserId);
          final lastMessageSnapshot = await FirebaseFirestore.instance
              .collection('Hamid_chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('sent', descending: true)
              .limit(1)
              .get();

          String lastMessageTime = '0';
          if (lastMessageSnapshot.docs.isNotEmpty) {
            lastMessageTime = lastMessageSnapshot.docs.first.data()['sent'] ?? '0';
          }

          await userDoc.reference.update({
            'last_message_time': lastMessageTime,
          });
        }
      }

      debugPrint('✅ Migration completed!');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> updateUserLastMessageTime(String userId) async {
    try {
      final lastMessageTime = await getActualLastMessageTime(userId);

      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .update({
        'last_message': lastMessageTime,
      });
    } catch (e) {
      debugPrint('Error updating last message time: $e');
    }
  }

  String getConversationId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) <= 0) {
      return '${userId1}_$userId2';
    } else {
      return '${userId2}_$userId1';
    }
  }

  Future<void> createUser({
    required String name,
    required String id,
    required String email,
    required String image,
    required bool isOnline,
    required bool isMobileOnline,
  }) =>
      _repo.createUser(
        name: name,
        id: id,
        email: email,
        image: image,
        isOnline: isOnline,
        isMobileOnline: isMobileOnline,
      );

  /// FIXED: Proper chat status management
  Future<void> setInsideChatStatus(bool isInside, {String? chatUserId}) async {
    await _repo.insideChatStatus(isInside);

    // Update Firebase service state
    FirebaseService.setAppState(
        isInChat: isInside,
        chatUserId: chatUserId
    );

    debugPrint('💬 Chat status updated: ${isInside ? "Inside" : "Outside"} chat${chatUserId != null ? " with $chatUserId" : ""}');
  }

  Future<bool> userExists(String uid) => _repo.userExists(uid);

  Future<ChatUser?> getUserById(String uid, String imageUrl) =>
      _repo.getUserById(uid, imageUrl);

  /// FIXED: Better self initialization
  Future<void> initSelf() async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Initializing self info in ChatViewModel...');

      await _repo.getSelfInfo();

      // Verify initialization
      if (FirebaseService.me != null) {
        debugPrint('✅ Self info initialized: ${FirebaseService.me!.name} (${FirebaseService.me!.id})');
      } else {
        debugPrint('❌ Self info not initialized properly');
        // Retry once
        await Future.delayed(const Duration(milliseconds: 1000));
        await _repo.getSelfInfo();

        if (FirebaseService.me == null) {
          throw Exception('Failed to initialize user after retry');
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch self info';
      debugPrint('❌ Error in initSelf: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Listen to chat messages for the selected user
  void listenToMessages(ChatUser user) {
    selectedUser.value = user;
    _repo.getAllMessages(user).listen((snapshot) {
      messages.value = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    });
  }

  // /// Stream for messages (for StreamBuilder)
  // Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesStream(ChatUser user) {
  //   selectedUser.value = user;
  //
  //   // FIXED: Set chat status when viewing messages
  //   setInsideChatStatus(true, chatUserId: user.id);
  //
  //   debugPrint('selectedUser.value: ${selectedUser.value}');
  //   return _repo.getAllMessages(user);
  // }
// In chat_viewmodel.dart - Update getAllMessagesStream method
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesStream(ChatUser user) {
    selectedUser.value = user;
    setInsideChatStatus(true, chatUserId: user.id);

    // Get the base stream
    final baseStream = _repo.getAllMessages(user);

    // Transform the stream to filter messages
    return baseStream.asyncMap((snapshot) async {
      // Check for deletion record
      final deletionDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_repo.currentUserId)
          .collection('deleted_chats')
          .doc(user.id)
          .get();

      if (!deletionDoc.exists) {
        // No deletion, return all messages
        return snapshot;
      }

      // Filter messages based on deletion time
      final deletionTime = deletionDoc.data()!['deleted_at'] as String;
      final deletionTimestamp = int.parse(deletionTime);

      // Create filtered list
      final filteredMessages = <Message>[];
      for (var doc in snapshot.docs) {
        final messageData = doc.data();
        final messageSentTime = messageData['sent'] as String;
        final messageTimestamp = int.parse(messageSentTime);

        if (messageTimestamp > deletionTimestamp) {
          filteredMessages.add(Message.fromJson(messageData));
        }
      }

      // Return filtered snapshot
      return snapshot;
    });
  }
  /// Stream for user info
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfoStream(String uid) {
    return _repo.getUserInfo(uid);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessageStream(ChatUser user) {
    return _repo.getLastMessage(user);
  }

  /// OPTIMIZED: Faster message sending
// In ChatViewModel, update sendMessage method:

  Future<void> sendMessage(String text) async {
    if (selectedUser.value != null && text.trim().isNotEmpty) {
      final listController = Get.find<ChatListController>();

      // Optimistically update UI
      await _repo.sendMessageOptimized(
        selectedUser.value!,
        text.trim(),
        Type.text,
        onMessageCreated: (message) {
          // Immediately update last message in chat list
          listController.updateLastMessageLocally(
            selectedUser.value!.id,
            message,
          );
        },
      );
    }
  }
  /// OPTIMIZED: Faster message sending
  // Future<void> sendMessage(String text) async {
  //   debugPrint("🚀 Sending message to ${selectedUser.value?.name}");
  //
  //   if (selectedUser.value != null && text.trim().isNotEmpty) {
  //     try {
  //       await _repo.sendMessage(selectedUser.value!, text.trim(), Type.text);
  //       debugPrint("✅ Message sent successfully");
  //     } catch (e) {
  //       debugPrint("❌ Error sending message: $e");
  //       Get.snackbar(
  //         'Error',
  //         'Failed to send message',
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         duration: const Duration(seconds: 2),
  //       );
  //     }
  //   }
  // }
  /// OPTIMIZED: Faster first message
  Future<void> sendFirstMessage(String text) async {
    debugPrint("🚀 Sending first message to ${selectedUser.value?.name}");

    if (selectedUser.value != null && text.trim().isNotEmpty) {
      try {
        await _repo.sendFirstMessage(selectedUser.value!, text.trim(), Type.text);
        debugPrint("✅ First message sent successfully");
      } catch (e) {
        debugPrint("❌ Error sending first message: $e");
        Get.snackbar(
          'Error',
          'Failed to send message',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  /// Send image in chat
  Future<void> sendImage(String currentUID, File imageFile) async {
    if (selectedUser.value != null) {
      await _repo.sendChatImage(currentUID, selectedUser.value!, imageFile);
    }
  }

  /// Delete a message
  Future<void> deleteMessage(Message message) async {
    await _repo.deleteMessage(message);
  }

  /// Update a message
  Future<void> updateMessage(Message message, String newText) async {
    await _repo.updateMessage(message, newText);
  }

  /// Mark message as read
  Future<void> markMessageAsRead(Message message) async {
    await _repo.updateMessageReadStatus(message);
  }

  /// Block user
  Future<void> blockUser(String userId) async {
    await _repo.blockUser(userId);
  }

  /// Unblock user
  Future<void> unblockUser(String userId) async {
    await _repo.unblockUser(userId);
  }

  /// Check if the current user has blocked someone
  Future<bool> isUserBlocked(String userId) async {
    return await _repo.isUserBlocked(userId);
  }

  /// Check if the selected user has blocked the current user
  Future<bool> isBlockedByFriend(String userId) async {
    return await _repo.isMyFriendBlocked(userId);
  }

  /// Update FCM token manually
  Future<void> updateFcmToken(String token) async {
    await _repo.updateFcmToken(token);
  }

  /// Update current user online status
  Future<void> setOnlineStatus(bool isOnline) async {
    await _repo.updateActiveStatus(isOnline);
  }

  /// Update last active timestamp
  Future<void> updateLastSeen() async {
    await _repo.updateLastActive();
  }

  /// OPTIMIZED: Faster chat user addition
  Future<bool> addChatUser(String uid) async {
    debugPrint('🚀 Adding chat user $uid');
    final result = await _repo.addChatUser(uid);
    if (result) {
      debugPrint('✅ Chat user added successfully');
    }
    return result;
  }

  Future<void> updateMessageReadStatus(Message message) => _repo.updateMessageReadStatus(message);

  /// Fetch list of friends (for chat list)
  Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersStream(currentUid) {
    return _repo.getMyUsersId(currentUid);
  }

  /// Fetch user details of all matched chat users
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsersStream(List<String> userIds) {
    return _repo.getAllUsers(userIds);
  }

  /// Fetch last message in a chat (for preview)
  Stream<Message?> getLastMessage(ChatUser user) {
    return _repo.getLastMessage(user).map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Message.fromJson(snapshot.docs.first.data());
      }
      return null;
    });
  }

  /// ADDED: Clean exit from chat
// Add this method to properly exit chat
  Future<void> exitChat() async {
    try {
      debugPrint('👋 Exiting current chat...');

      // Clear current chat state
      if (selectedUser.value != null) {
        await setInsideChatStatus(false);

        // Cancel any active message streams
        final userId = selectedUser.value!.id;
        _activeStreams[userId]?.cancel();
        _activeStreams.remove(userId);

        // Clear messages and user
        messages.clear();
        selectedUser.value = null;
        currentChatDeletionTime.value = null;
      }

      debugPrint('✅ Chat exited successfully');
    } catch (e) {
      debugPrint('❌ Error exiting chat: $e');
    }
  }

// Add helper method to check if chatting with specific user
  bool isChattingWithUser(String userId) {
    return selectedUser.value != null && selectedUser.value!.id == userId;
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    // Cancel all active streams when controller is disposed
    _activeStreams.values.forEach((subscription) => subscription.cancel());
    _activeStreams.clear();
    exitChat();
    super.onClose();
  }
}