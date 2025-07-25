// chat_list_viewmodel.dart - Optimized to prevent unnecessary updates

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/export.dart';
import '../domain/export.dart';

class ChatListController extends GetxController {
  final useCase = Get.find<UserManagementUseCase>();

  // Reactive variables
  final RxList<ChatUser> chatUsers = <ChatUser>[].obs;
  final RxList<ChatUser> searchResults = <ChatUser>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;

  // Streams
  StreamSubscription? _myUsersSubscription;
  StreamSubscription? _allUsersSubscription;

  // Track state to prevent unnecessary updates
  DateTime? _lastRefreshTime;
  List<String> _lastUserOrder = [];
  Map<String, ChatUser> _userCache = {};

  // Real-time message listeners
  final Map<String, StreamSubscription> _messageListeners = {};
  final Map<String, RxString> _lastMessageTimes = {};
  final Map<String, Rx<Message?>> _lastMessages = {};

  String get currentUserId => useCase.getUserId().toString();

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 ChatListController initialized with blinking prevention');
    _initializeStreams();
  }

  void _initializeStreams() {
    debugPrint('🔄 Setting up optimized streams...');

    // Cancel existing subscriptions
    _myUsersSubscription?.cancel();
    _allUsersSubscription?.cancel();

    // Stream with optimized sorting
    _myUsersSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
        .doc(currentUserId)
        .collection('my_users')
        .orderBy('last_message_time', descending: true)
        .snapshots()
        .listen((myUsersSnapshot) {

      debugPrint('📥 My users stream: ${myUsersSnapshot.docs.length} users');

      final userIds = myUsersSnapshot.docs.map((e) => e.id).toList();

      if (userIds.isEmpty) {
        debugPrint('📋 No chat users found');
        chatUsers.clear();
        _clearListeners();
        isLoading.value = false;
        isRefreshing.value = false;
        return;
      }

      // Fetch user details
      _fetchAndUpdateUsers(userIds);
    }, onError: (error) {
      debugPrint('❌ Error in my users stream: $error');
      isLoading.value = false;
      isRefreshing.value = false;
    });
  }

  void _fetchAndUpdateUsers(List<String> userIds) {
    debugPrint('🔄 Fetching user details for ${userIds.length} users...');

    _allUsersSubscription?.cancel();

    _allUsersSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
        .where('id', whereIn: userIds)
        .snapshots()
        .listen((snapshot) {

      debugPrint('👥 Received ${snapshot.docs.length} user details');

      final newUsers = <ChatUser>[];

      for (var doc in snapshot.docs) {
        try {
          final user = ChatUser.fromJson(doc.data());
          newUsers.add(user);
          debugPrint('✅ Added user: ${user.name} (${user.id})');

          // Setup message listener for this user
          if (!_messageListeners.containsKey(user.id)) {
            _listenToUserMessages(user);
          }
        } catch (e) {
          debugPrint('❌ Error parsing user: $e');
        }
      }

      // Sort based on userIds order to maintain last message time order
      newUsers.sort((a, b) =>
          userIds.indexOf(a.id).compareTo(userIds.indexOf(b.id))
      );

      // Update the chat users list
      chatUsers.assignAll(newUsers);

      // Clean up listeners for users no longer in the list
      _cleanupStaleListeners(newUsers);

      isLoading.value = false;
      isRefreshing.value = false;
      _lastRefreshTime = DateTime.now();

      debugPrint('✅ Chat list updated with ${newUsers.length} users');
    }, onError: (error) {
      debugPrint('❌ Error fetching user details: $error');
      isLoading.value = false;
      isRefreshing.value = false;
    });
  }

  void _listenToUserMessages(ChatUser user) {
    debugPrint('👂 Setting up message listener for ${user.name}');

    // Cancel existing listener if any
    _messageListeners[user.id]?.cancel();

    // Create reactive variables for this user
    _lastMessageTimes[user.id] ??= RxString('0');
    _lastMessages[user.id] ??= Rx<Message?>(null);

    // Listen to last message
    final chatId = getConversationId(currentUserId, user.id);

    _messageListeners[user.id] = FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {

      if (snapshot.docs.isNotEmpty) {
        final message = Message.fromJson(snapshot.docs.first.data());
        _lastMessages[user.id]!.value = message;
        _lastMessageTimes[user.id]!.value = message.sent;

        debugPrint('💬 Last message updated for ${user.name}');

        // Update user position if needed
        _updateUserPositionIfNeeded(user.id, message.sent);
      }
    }, onError: (error) {
      debugPrint('❌ Error listening to messages for ${user.name}: $error');
    });
  }

  void _cleanupStaleListeners(List<ChatUser> currentUsers) {
    final currentUserIds = currentUsers.map((u) => u.id).toSet();

    // Only clean up listeners for users NOT in the current list
    _messageListeners.keys.toList().forEach((userId) {
      if (!currentUserIds.contains(userId)) {
        debugPrint('🧹 Cleaning up listener for removed user: $userId');
        _messageListeners[userId]?.cancel();
        _messageListeners.remove(userId);
        _lastMessages.remove(userId);
        _lastMessageTimes.remove(userId);
      }
    });
  }

  void _updateUserPositionIfNeeded(String userId, String messageTime) {
    // Find current position
    final currentIndex = chatUsers.indexWhere((u) => u.id == userId);
    if (currentIndex == -1 || currentIndex == 0) return;

    // Check if needs to move up
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
      // Smoothly move user without rebuilding entire list
      final user = chatUsers.removeAt(currentIndex);
      chatUsers.insert(targetIndex, user);
      debugPrint('📍 Moved ${user.name} to position $targetIndex');
    }
  }

  // Get reactive last message for a user
  Rx<Message?> getLastMessageReactive(String userId) {
    return _lastMessages[userId] ?? Rx<Message?>(null);
  }

  // Update last message locally (for optimistic updates)
  void updateLastMessageLocally(String userId, Message message) {
    if (_lastMessages.containsKey(userId)) {
      _lastMessages[userId]!.value = message;
      _lastMessageTimes[userId]!.value = message.sent;
      _updateUserPositionIfNeeded(userId, message.sent);
    }
  }

  // Reconnect listeners after app resume
  void reconnectListeners() {
    debugPrint('🔄 Reconnecting message listeners...');
    for (var user in chatUsers) {
      _listenToUserMessages(user);
    }
  }

  void _clearListeners() {
    debugPrint('🧹 Clearing all message listeners...');
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

  Future<void> deleteChat(ChatUser user) async {
    try {
      debugPrint('🗑️ Deleting chat with ${user.name}...');

      // Stop listening to this user's messages first
      _messageListeners[user.id]?.cancel();
      _messageListeners.remove(user.id);
      _lastMessages.remove(user.id);
      _lastMessageTimes.remove(user.id);

      // Remove from UI
      chatUsers.removeWhere((u) => u.id == user.id);

      // Create batch for atomic operation
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Remove from my list
      batch.delete(
        FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(currentUserId)
            .collection('my_users')
            .doc(user.id),
      );

      // Remove from their list
      batch.delete(
        FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(user.id)
            .collection('my_users')
            .doc(currentUserId),
      );

      // Execute batch
      await batch.commit();

      // Delete messages
      final chatId = getConversationId(currentUserId, user.id);
      final messages = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .get();

      if (messages.docs.isNotEmpty) {
        final deleteBatch = FirebaseFirestore.instance.batch();
        for (var doc in messages.docs) {
          deleteBatch.delete(doc.reference);
        }
        await deleteBatch.commit();
      }

      Get.snackbar(
        'Success',
        'Chat with ${user.name} deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      debugPrint('✅ Chat deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting chat: $e');
      Get.snackbar(
        'Error',
        'Failed to delete chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Force refresh
  void forceRefresh() {
    debugPrint('🔄 Force refreshing chat list...');

    if (isRefreshing.value) {
      debugPrint('⏳ Already refreshing, skipping...');
      return;
    }

    isRefreshing.value = true;

    // Clear cache
    _userCache.clear();
    _lastUserOrder.clear();

    // Re-initialize streams
    _initializeStreams();

    debugPrint('✅ Force refresh initiated');
  }

  @override
  void onClose() {
    debugPrint('🔚 ChatListController closing...');
    _myUsersSubscription?.cancel();
    _allUsersSubscription?.cancel();
    _clearListeners();
    _userCache.clear();
    _lastUserOrder.clear();
    super.onClose();
  }
}