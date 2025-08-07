// chat_list_viewmodel.dart - Fixed loading state management

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../core/export.dart';
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
          .collection('Hamid_users')
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

  // Updated delete method with GetX
  // Updated deleteChat method in ChatListController
  Future<void> deleteChat(ChatUser user) async {
    try {
      debugPrint('🗑️ Deleting chat with ${user.name}...');

      // ADDED: Clear cached messages from ChatViewModel
      if (Get.isRegistered<ChatViewModel>()) {
        final chatController = Get.find<ChatViewModel>();
        chatController.cachedMessagesPerUser.remove(user.id);
        debugPrint('🧹 Cleared cached messages for user: ${user.id}');
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
            .collection('Hamid_users')
            .doc(currentUserId)
            .collection('my_users')
            .doc(user.id),
      );

      // Store deletion record
      batch.set(
        FirebaseFirestore.instance
            .collection('Hamid_users')
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
          .collection('Hamid_users')
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
        .collection('Hamid_users')
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
        .collection('Hamid_users')
        .where('id', whereIn: userIds)
        .snapshots()
        .listen(
          (snapshot) {
        final newUsers = <ChatUser>[];

        for (var doc in snapshot.docs) {
          try {
            final user = ChatUser.fromJson(doc.data());
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

        debugPrint('✅ Updated chat list with ${newUsers.length} users');
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
        .collection('Hamid_chats')
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
