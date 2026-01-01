// chat_list_viewmodel.dart - Fixed loading state management

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../core/export.dart';
import '../core/services/env_config_service.dart';
import '../domain/export.dart';
import 'chat_viewmodel.dart';

class ChatListController extends GetxController {
  final useCase = Get.find<UserManagementUseCase>();

  // Reactive variables
  final RxList<ChatUser> chatUsers = <ChatUser>[].obs;
  final RxList<ChatUser> searchResults = <ChatUser>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  // Add this to prevent loading state during navigation
  final RxBool isNavigatingToChat = false.obs;
  // Add flag to track if streams are active
  bool _streamsActive = false;
  // Deletion tracking
  final RxMap<String, String> deletionTimestamps = <String, String>{}.obs;

  // Streams
  StreamSubscription? _myUsersSubscription;
  StreamSubscription? _allUsersSubscription;

  // Real-time message listeners
  final Map<String, StreamSubscription> _messageListeners = {};
  final Map<String, RxString> _lastMessageTimes = {};
  final Map<String, Rx<Message?>> _lastMessages = {};

  String get currentUserId => useCase.getUserId().toString();

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 ChatListController initialized');
    // _initializeStreams();
    // _loadDeletionRecords();
    _initializeController();
    // Process deliveries after a short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      _processMyPendingDeliveries();
    });
  }
  // Add this method to chat_list_viewmodel.dart
  Future<void> _processMyPendingDeliveries() async {
    try {
      final currentUserId = useCase.getUserId().toString();
      int processedCount = 0;

      // Process deliveries for all active chats
      for (var user in chatUsers) {
        final conversationId = getConversationId(currentUserId, user.id);

        final undelivered = await FirebaseFirestore.instance
            .collection(EnvConfig.firebaseChatsCollection)
            .doc(conversationId)
            .collection('messages')
            .where('toId', isEqualTo: currentUserId)
            .where('delivered', isEqualTo: '')
            .limit(20)
            .get();

        if (undelivered.docs.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          final deliveryTime = DateTime.now().millisecondsSinceEpoch.toString();

          for (var doc in undelivered.docs) {
            batch.update(doc.reference, {
              'delivered': deliveryTime,
              'status': 'delivered',
            });
            processedCount++;
          }

          await batch.commit();
        }
      }

      if (processedCount > 0) {
        debugPrint('✅ Processed $processedCount pending deliveries in chat list');
      }
    } catch (e) {
      debugPrint('❌ Error processing chat list deliveries: $e');
    }
  }
  Future<void> _initializeController() async {
    // Load deletion records first
    await _loadDeletionRecords();
    // Then initialize streams
    _initializeStreams();
  }

  // Load deletion records on init
  Future<void> _loadDeletionRecords() async {
    try {
      final deletionSnapshot = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(currentUserId)
          .collection('deleted_chats')
          .get();

      for (var doc in deletionSnapshot.docs) {
        deletionTimestamps[doc.id] = doc.data()['deleted_at'] as String;
      }
      debugPrint('📋 Loaded ${deletionTimestamps.length} deletion records');
    } catch (e) {
      debugPrint('❌ Error loading deletion records: $e');
    }
  }
// Add these methods to your ChatListController class in chat_list_viewmodel.dart

// ============================================
// MESSAGE STATE SYNCHRONIZATION METHODS
// ============================================

// Method to refresh a specific user's data and last message
  Future<void> refreshSpecificUser(String userId) async {
    try {
      debugPrint('🔄 Refreshing user: $userId');

      final index = chatUsers.indexWhere((user) => user.id == userId);
      if (index == -1) {
        debugPrint('⚠️ User not found in chat list: $userId');
        return;
      }

      final user = chatUsers[index];

      // Get the latest message for this user
      final chatId = getConversationId(currentUserId, userId);
      final lastMessageSnapshot = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseChatsCollection)
          .doc(chatId)
          .collection('messages')
          .orderBy('sent', descending: true)
          .limit(1)
          .get();

      if (lastMessageSnapshot.docs.isNotEmpty) {
        final message = Message.fromJson(lastMessageSnapshot.docs.first.data());

        // Check if message should be shown (after deletion)
        final deletionTime = deletionTimestamps[userId];
        if (deletionTime != null) {
          final messageTime = int.parse(message.sent);
          final deletedAt = int.parse(deletionTime);

          if (messageTime <= deletedAt) {
            // Message is older than deletion, don't show
            _lastMessages[userId]?.value = null;
            _lastMessageTimes[userId]?.value = '0';
            return;
          }
        }

        // Update the last message
        _lastMessages[userId] ??= Rx<Message?>(null);
        _lastMessages[userId]!.value = message;

        _lastMessageTimes[userId] ??= RxString('0');
        _lastMessageTimes[userId]!.value = message.sent;

        // Update user position if needed
        _updateUserPositionIfNeeded(userId, message.sent);

        // Force UI refresh
        chatUsers.refresh();

        debugPrint('✅ User refreshed with latest message');
      } else {
        // No messages, clear last message
        _lastMessages[userId]?.value = null;
        _lastMessageTimes[userId]?.value = '0';
        chatUsers.refresh();
      }
    } catch (e) {
      debugPrint('❌ Error refreshing user: $e');
    }
  }

// Method to update message status in the chat list
  void updateMessageStatus(String userId, String messageId, MessageStatus status) {
    try {
      debugPrint('📊 Updating message status: $messageId -> ${status.name}');

      // Check if we have this user's last message
      if (!_lastMessages.containsKey(userId)) {
        debugPrint('⚠️ No last message found for user: $userId');
        return;
      }

      final lastMessage = _lastMessages[userId]?.value;
      if (lastMessage == null) {
        debugPrint('⚠️ Last message is null for user: $userId');
        return;
      }

      // Only update if this is the last message
      if (lastMessage.sent == messageId) {
        // Update the message status
        lastMessage.status = status;

        // Update timestamps based on status
        if (status == MessageStatus.delivered) {
          lastMessage.delivered = DateTime.now().millisecondsSinceEpoch.toString();
        } else if (status == MessageStatus.read) {
          final now = DateTime.now().millisecondsSinceEpoch.toString();
          lastMessage.delivered = now;
          lastMessage.read = now;
        }

        // Trigger reactive update
        _lastMessages[userId]!.value = null; // Clear first
        _lastMessages[userId]!.value = lastMessage; // Then reassign

        // Force UI refresh
        chatUsers.refresh();

        debugPrint('✅ Message status updated in chat list');
      } else {
        debugPrint('ℹ️ Message is not the last message, skipping update');
      }
    } catch (e) {
      debugPrint('❌ Error updating message status: $e');
    }
  }

// Method to refresh user's messages after deletion
  Future<void> refreshUserMessages(String userId) async {
    try {
      debugPrint('🔄 Refreshing messages for user: $userId');

      // Cancel existing listener
      _messageListeners[userId]?.cancel();
      _messageListeners.remove(userId);

      // Find the user
      final user = chatUsers.firstWhereOrNull((u) => u.id == userId);
      if (user == null) {
        debugPrint('⚠️ User not found: $userId');
        return;
      }

      // Re-establish message listener
      _listenToUserMessages(user);

      // Force immediate refresh
      await refreshSpecificUser(userId);

      debugPrint('✅ User messages refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing user messages: $e');
    }
  }

// Method to handle message deletion notification
  void onMessageDeleted(String userId, String messageId) {
    try {
      debugPrint('🗑️ Message deleted notification: $messageId');

      // Check if this was the last message
      final lastMessage = _lastMessages[userId]?.value;
      if (lastMessage != null && lastMessage.sent == messageId) {
        // Refresh to get the new last message
        refreshSpecificUser(userId);
      }
    } catch (e) {
      debugPrint('❌ Error handling message deletion: $e');
    }
  }

// Method to force update a specific user's position in the list
  void forceUpdateUserPosition(String userId) {
    try {
      final messageTime = _lastMessageTimes[userId]?.value ?? '0';
      _updateUserPositionIfNeeded(userId, messageTime);
      chatUsers.refresh();
    } catch (e) {
      debugPrint('❌ Error updating user position: $e');
    }
  }

// Method to check if a user has unread messages
  bool hasUnreadMessages(String userId) {
    final lastMessage = _lastMessages[userId]?.value;
    if (lastMessage == null) return false;

    // Check if the message is from the other user and not read
    return lastMessage.fromId == userId &&
        lastMessage.read.isEmpty &&
        lastMessage.toId == currentUserId;
  }

// Method to get unread count for a specific user
  int getUnreadCount(String userId) {
    // This would need to be implemented with a proper query
    // For now, return 1 if there's an unread message, 0 otherwise
    return hasUnreadMessages(userId) ? 1 : 0;
  }

// Method to mark all messages from a user as delivered
  Future<void> markUserMessagesAsDelivered(String userId) async {
    try {
      final chatId = getConversationId(currentUserId, userId);

      // Get undelivered messages
      final undelivered = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseChatsCollection)
          .doc(chatId)
          .collection('messages')
          .where('toId', isEqualTo: currentUserId)
          .where('fromId', isEqualTo: userId)
          .where('delivered', isEqualTo: '')
          .limit(50)
          .get();

      if (undelivered.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      final deliveryTime = DateTime.now().millisecondsSinceEpoch.toString();

      for (var doc in undelivered.docs) {
        batch.update(doc.reference, {
          'delivered': deliveryTime,
          'status': MessageStatus.delivered.name,
        });
      }

      await batch.commit();

      // Update local state if this affects the last message
      final lastMessage = _lastMessages[userId]?.value;
      if (lastMessage != null && (lastMessage.delivered ?? '').isEmpty) {
        lastMessage.delivered = deliveryTime;
        lastMessage.status = MessageStatus.delivered;
        _lastMessages[userId]!.value = null; // Clear
        _lastMessages[userId]!.value = lastMessage; // Reassign
        chatUsers.refresh();
      }

      debugPrint('✅ Marked messages as delivered for user: $userId');
    } catch (e) {
      debugPrint('❌ Error marking messages as delivered: $e');
    }
  }

// Method to sync all message states
  Future<void> syncAllMessageStates() async {
    try {
      debugPrint('🔄 Syncing all message states...');

      for (var user in chatUsers) {
        await markUserMessagesAsDelivered(user.id);
      }

      debugPrint('✅ All message states synced');
    } catch (e) {
      debugPrint('❌ Error syncing message states: $e');
    }
  }

// Method to handle real-time status updates
  void handleRealtimeStatusUpdate(String userId, String messageId, MessageStatus status) {
    // Update in UI immediately
    updateMessageStatus(userId, messageId, status);

    // If this is a read status, update any previous unread indicators
    if (status == MessageStatus.read) {
      // Could trigger any UI updates for read receipts here
      debugPrint('✅ Message marked as read: $messageId');
    }
  }

// Enhanced cleanup method
  void cleanupUserData(String userId) {
    try {
      // Cancel message listener
      _messageListeners[userId]?.cancel();
      _messageListeners.remove(userId);

      // Clear reactive data
      _lastMessages.remove(userId);
      _lastMessageTimes.remove(userId);

      // Remove from chat users
      chatUsers.removeWhere((u) => u.id == userId);

      debugPrint('✅ Cleaned up data for user: $userId');
    } catch (e) {
      debugPrint('❌ Error cleaning up user data: $e');
    }
  }
  // Updated delete method with GetX
  // Updated deleteChat method in ChatListController
  Future<void> deleteChat(ChatUser user) async {
    try {
      debugPrint('🗑️ Deleting chat with ${user.name}...');

      // ADDED: Clear cached messages from ChatViewModel and Hive
      if (Get.isRegistered<ChatViewModel>()) {
        final chatController = Get.find<ChatViewModel>();
        chatController.cachedMessagesPerUser.remove(user.id);
        // CRITICAL: Also clear Hive cache to prevent flash of deleted messages
        await chatController.clearHiveCacheForUser(user.id);
        debugPrint('🧹 Cleared cached messages (memory + Hive) for user: ${user.id}');
      }

      // Stop listening to this user's messages
      _messageListeners[user.id]?.cancel();
      _messageListeners.remove(user.id);
      _lastMessages.remove(user.id);
      _lastMessageTimes.remove(user.id);

      // Remove from UI immediately
      chatUsers.removeWhere((u) => u.id == user.id);

      final deletionTime = DateTime.now().millisecondsSinceEpoch.toString();

      // Update deletion tracking
      deletionTimestamps[user.id] = deletionTime;

      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Remove from my_users
      batch.delete(
        FirebaseFirestore.instance
            .collection(EnvConfig.firebaseUsersCollection)
            .doc(currentUserId)
            .collection('my_users')
            .doc(user.id),
      );

      // Store deletion record
      batch.set(
        FirebaseFirestore.instance
            .collection(EnvConfig.firebaseUsersCollection)
            .doc(currentUserId)
            .collection('deleted_chats')
            .doc(user.id),
        {
          'deleted_at': deletionTime,
          'user_name': user.name,
          'user_image': user.image,
          'deleted_on': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();

      Get.snackbar(
        'Success',
        'Chat deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );

      debugPrint('✅ Chat deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting chat: $e');

      // Restore on error
      if (!chatUsers.any((u) => u.id == user.id)) {
        chatUsers.add(user);
        _listenToUserMessages(user);
      }

      Get.snackbar(
        'Error',
        'Failed to delete chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get deletion timestamp for a user
  String? getDeletionTimestamp(String userId) {
    return deletionTimestamps[userId];
  }

  // Clear deletion record when user actively chats
  Future<void> clearDeletionRecord(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(currentUserId)
          .collection('deleted_chats')
          .doc(userId)
          .delete();

      deletionTimestamps.remove(userId);
      // ADDED: Also clear any cached messages for this user when clearing deletion record
      if (Get.isRegistered<ChatViewModel>()) {
        final chatController = Get.find<ChatViewModel>();
        chatController.cachedMessagesPerUser.remove(userId);
        debugPrint('🧹 Cleared cached messages when clearing deletion record for: $userId');
      }
      debugPrint('✅ Deletion record cleared for $userId');
    } catch (e) {
      debugPrint('❌ Error clearing deletion record: $e');
    }
  }

  void _initializeStreams() {
    // Don't reinitialize if already active
    if (_streamsActive) {
      debugPrint('📡 Streams already active, skipping initialization');
      return;
    }

    debugPrint('🔄 Setting up streams...');
    _streamsActive = true;

    // Cancel existing subscriptions
    _myUsersSubscription?.cancel();
    _allUsersSubscription?.cancel();

    // Start loading only if not already loading
    if (!isLoading.value && chatUsers.isEmpty) {
      isLoading.value = true;
    }

    _myUsersSubscription = FirebaseFirestore.instance
        .collection(EnvConfig.firebaseUsersCollection)
        .doc(currentUserId)
        .collection('my_users')
        .orderBy('last_message_time', descending: true)
        .snapshots()
        .listen(
          (myUsersSnapshot) {
        debugPrint('📥 My users stream: ${myUsersSnapshot.docs.length} users');

        final userIds = myUsersSnapshot.docs.map((e) => e.id).toList();

        if (userIds.isEmpty) {
          chatUsers.clear();
          _clearListeners();
          isLoading.value = false;
          isRefreshing.value = false;
          return;
        }

        _fetchAndUpdateUsers(userIds);
      },
      onError: (error) {
        debugPrint('❌ Error in my users stream: $error');
        isLoading.value = false;
        isRefreshing.value = false;
        _streamsActive = false;
      },
      cancelOnError: false, // Don't cancel on error
    );
  }
  void _fetchAndUpdateUsers(List<String> userIds) {
    _allUsersSubscription?.cancel();

    _allUsersSubscription = FirebaseFirestore.instance
        .collection(EnvConfig.firebaseUsersCollection)
        .where('id', whereIn: userIds)
        .snapshots()
        .listen(
          (snapshot) async {
        final newUsers = <ChatUser>[];

        for (var doc in snapshot.docs) {
          try {
            final user = ChatUser.fromJson(doc.data());

            // Check if user has at least 1 message
            final hasMessages = await _userHasMessages(user.id);
            if (!hasMessages) {
              debugPrint('⏭️ Skipping user ${user.name} - no messages yet');
              continue; // Skip users without messages
            }

            newUsers.add(user);

            // Setup message listener for each user
            if (!_messageListeners.containsKey(user.id)) {
              _listenToUserMessages(user);
            }
          } catch (e) {
            debugPrint('❌ Error parsing user: $e');
          }
        }

        // Sort by original order from my_users
        newUsers.sort((a, b) => userIds.indexOf(a.id).compareTo(userIds.indexOf(b.id)));

        // Update the chat users list
        chatUsers.assignAll(newUsers);

        // Cleanup old listeners
        _cleanupStaleListeners(newUsers);

        // Reset loading states
        if (isLoading.value) {
          isLoading.value = false;
        }
        if (isRefreshing.value) {
          isRefreshing.value = false;
        }
        if (isNavigatingToChat.value) {
          isNavigatingToChat.value = false;
        }

        debugPrint('✅ Updated chat list with ${newUsers.length} users (filtered by messages)');
      },
      onError: (error) {
        debugPrint('❌ Error fetching user details: $error');
        isLoading.value = false;
        isRefreshing.value = false;
        isNavigatingToChat.value = false;
        _streamsActive = false;
      },
      cancelOnError: false, // Don't cancel on error
    );
  }

  /// Check if user has at least 1 message in the conversation
  Future<bool> _userHasMessages(String userId) async {
    try {
      final chatId = getConversationId(currentUserId, userId);

      // Check if any message exists in this conversation
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseChatsCollection)
          .doc(chatId)
          .collection('messages')
          .limit(1)
          .get();

      // Also check deletion timestamp - if deleted, check for new messages after deletion
      final deletionTime = deletionTimestamps[userId];
      if (deletionTime != null && messagesSnapshot.docs.isNotEmpty) {
        final message = messagesSnapshot.docs.first.data();
        final messageTime = int.parse(message['sent'] ?? '0');
        final deletedAt = int.parse(deletionTime);

        // Only count messages after deletion
        if (messageTime <= deletedAt) {
          return false;
        }
      }

      return messagesSnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking user messages: $e');
      return false;
    }
  }
  // FIXED: Method to ensure streams are active
  ensureStreamsActive() {
    debugPrint('🔍 Checking stream status...');

    if (!_streamsActive || _myUsersSubscription == null) {
      debugPrint('📡 Streams not active, reinitializing...');
      _initializeStreams();
    }
    //else if (chatUsers.isEmpty && !isLoading.value) {
    //   debugPrint('📡 Chat users empty, forcing refresh...');
    //   forceRefresh();
    //}
    else {
      debugPrint('✅ Streams are active with ${chatUsers.length} users');
    }
  }
  void _listenToUserMessages(ChatUser user) {
    _messageListeners[user.id]?.cancel();

    _lastMessageTimes[user.id] ??= RxString('0');
    _lastMessages[user.id] ??= Rx<Message?>(null);

    final chatId = getConversationId(currentUserId, user.id);

    _messageListeners[user.id] = FirebaseFirestore.instance
        .collection(EnvConfig.firebaseChatsCollection)
        .doc(chatId)
        .collection('messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final message = Message.fromJson(snapshot.docs.first.data());

          // Check if message should be shown (after deletion)
          final deletionTime = deletionTimestamps[user.id];
          if (deletionTime != null) {
            final messageTime = int.parse(message.sent);
            final deletedAt = int.parse(deletionTime);

            if (messageTime <= deletedAt) {
              // Message is older than deletion, don't show
              _lastMessages[user.id]!.value = null;
              _lastMessageTimes[user.id]!.value = '0';
              return;
            }
          }

          // AUTO-MARK AS DELIVERED (even in background)
          // Mark incoming messages as delivered if they're sent TO current user
          if (message.toId == currentUserId &&
              message.fromId == user.id &&
              message.delivered!.isEmpty) {
            _autoMarkAsDelivered(user.id, message.sent);
          }

          _lastMessages[user.id]!.value = message;
          _lastMessageTimes[user.id]!.value = message.sent;
          _updateUserPositionIfNeeded(user.id, message.sent);
        }
      },
      onError: (error) {
        debugPrint('❌ Error listening to messages: $error');
      },
    );
  }

  void _updateUserPositionIfNeeded(String userId, String messageTime) {
    final currentIndex = chatUsers.indexWhere((u) => u.id == userId);
    if (currentIndex == -1 || currentIndex == 0) return;

    bool needsMove = false;
    int targetIndex = 0;

    for (int i = 0; i < currentIndex; i++) {
      final otherUserId = chatUsers[i].id;
      final otherTime = _lastMessageTimes[otherUserId]?.value ?? '0';

      if (int.parse(messageTime) > int.parse(otherTime)) {
        needsMove = true;
        targetIndex = i;
        break;
      }
    }

    if (needsMove) {
      final user = chatUsers.removeAt(currentIndex);
      chatUsers.insert(targetIndex, user);
    }
  }

  // Auto-mark message as delivered (works even in background)
  Future<void> _autoMarkAsDelivered(String senderId, String messageId) async {
    try {
      final conversationId = getConversationId(currentUserId, senderId);
      final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseChatsCollection)
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
        'delivered': deliveredTime,
        'status': MessageStatus.delivered.name,
        'deliveryPending': false,
      });

      debugPrint('✅ Auto-marked message $messageId as delivered (background delivery)');
    } catch (e) {
      debugPrint('❌ Error auto-marking message as delivered: $e');
    }
  }

  void _cleanupStaleListeners(List<ChatUser> currentUsers) {
    final currentUserIds = currentUsers.map((u) => u.id).toSet();

    _messageListeners.keys.toList().forEach((userId) {
      if (!currentUserIds.contains(userId)) {
        _messageListeners[userId]?.cancel();
        _messageListeners.remove(userId);
        _lastMessages.remove(userId);
        _lastMessageTimes.remove(userId);
      }
    });
  }

  // FIXED: Better cleanup
  void _clearListeners() {
    for (var subscription in _messageListeners.values) {
      subscription.cancel();
    }
    _messageListeners.clear();
    _lastMessageTimes.clear();
    _lastMessages.clear();
  }

  String getConversationId(String userId1, String userId2) {
    return userId1.compareTo(userId2) <= 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  Rx<Message?> getLastMessageReactive(String userId) {
    return _lastMessages[userId] ?? Rx<Message?>(null);
  }

  void updateLastMessageLocally(String userId, Message message) {
    if (_lastMessages.containsKey(userId)) {
      _lastMessages[userId]!.value = message;
      _lastMessageTimes[userId]!.value = message.sent;
      _updateUserPositionIfNeeded(userId, message.sent);
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filteredUsers = chatUsers.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery);
    }).toList();

    searchResults.assignAll(filteredUsers);
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchResults.clear();
    }
  }

  // FIXED: Force refresh with proper state management
  void forceRefresh() {
    if (isRefreshing.value) return;

    debugPrint('🔄 Force refreshing chat list...');

    isRefreshing.value = true;
    _streamsActive = false; // Mark streams as inactive to force reinitialization

    // Clear existing data
    _clearListeners();

    // Small delay to ensure cleanup
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeStreams();
      _loadDeletionRecords();
    });
  }

  // Method to handle new user added to chat
  Future<void> onNewUserAdded(String userId) async {
    try {
      debugPrint('👤 New user added to chat: $userId');

      // Wait a bit for Firebase to sync
      await Future.delayed(const Duration(milliseconds: 500));

      // Force refresh to get the new user
      forceRefresh();

      debugPrint('✅ Chat list updated with new user');
    } catch (e) {
      debugPrint('❌ Error handling new user: $e');
    }
  }

  // FIXED: Reconnect listeners with state check
  // FIXED: Better reconnect logic
  void reconnectListeners() {
    debugPrint('🔄 Reconnecting message listeners...');

    // Don't reconnect if navigating to chat
    if (isNavigatingToChat.value) {
      debugPrint('⚠️ Skip reconnect - navigating to chat');
      return;
    }

    // Ensure streams are active first
    ensureStreamsActive();

    // Then reconnect message listeners
    for (var user in chatUsers) {
      if (!_messageListeners.containsKey(user.id)) {
        _listenToUserMessages(user);
      }
    }

    // Ensure loading states are reset
    isLoading.value = false;
    isRefreshing.value = false;
  }


  // FIXED: Method to properly reset all states with widget lock check
  void resetAllStates() {
    // Check if we can safely update states
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.detached) {
      debugPrint('⚠️ App detached, skipping state reset');
      return;
    }

    // Schedule state updates for next frame if widget tree is locked
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetStatesInternal();
      });
    } else {
      _resetStatesInternal();
    }
  }

  void _resetStatesInternal() {
    isLoading.value = false;
    isRefreshing.value = false;
    isNavigatingToChat.value = false;
    debugPrint('🔄 All states reset');
  }

  @override
  void onClose() {
    debugPrint('🗑️ Disposing ChatListController');
    _streamsActive = false;
    _myUsersSubscription?.cancel();
    _allUsersSubscription?.cancel();
    _clearListeners();
    super.onClose();
  }
}