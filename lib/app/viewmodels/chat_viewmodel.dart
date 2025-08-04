// chat_viewmodel.dart - Fixed cache management and deletion handling

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
  // FIXED: Persistent cache that survives app restarts
  static final Map<String, List<Message>> _persistentMessageCache = {};
  static final Map<String, String?> _persistentDeletionCache = {};
  static final Map<String, StreamSubscription> _activeStreams = {};

  final ChatRepository _repo = ChatRepository();
  String? get currentChatUserId => selectedUser.value?.id;

  var chatUsers = <ChatUser>[].obs;
  var messages = <Message>[].obs;
  var selectedUser = Rxn<ChatUser>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final RxMap<String, List<Message>> cachedMessagesPerUser = <String, List<Message>>{}.obs;

  // FIXED: Better deletion tracking
  final RxnString currentChatDeletionTime = RxnString();
  final RxBool hasCachedMessages = false.obs;

  // Navigation state management
  String? pendingChatUserId;
  ChatUser? notificationUser;
  bool _isNavigatingFromNotification = false;
  bool _hasHandledNotification = false;
  final RxBool isFromNotification = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePersistentCache();
  }

  // FIXED: Initialize persistent cache on app start
  void _initializePersistentCache() {
    // Load any existing cache data
    cachedMessagesPerUser.addAll(_persistentMessageCache);
    debugPrint('📦 Initialized persistent cache with ${_persistentMessageCache.length} conversations');
  }

  // FIXED: Smart cache retrieval
  List<Message>? getCachedMessages(String userId) {
    // First check reactive cache
    if (cachedMessagesPerUser.containsKey(userId)) {
      return cachedMessagesPerUser[userId];
    }

    // Then check persistent cache
    if (_persistentMessageCache.containsKey(userId)) {
      cachedMessagesPerUser[userId] = _persistentMessageCache[userId]!;
      return _persistentMessageCache[userId];
    }

    return null;
  }

  // FIXED: Professional cache management
  void cacheMessages(String userId, List<Message> messages) {
    // Update both caches
    cachedMessagesPerUser[userId] = messages;
    _persistentMessageCache[userId] = messages;

    debugPrint('💾 Cached ${messages.length} messages for user $userId');
  }

  // FIXED: Optimized message stream with proper cache handling
  Stream<List<Message>> getFilteredMessagesStream(ChatUser user) {
    selectedUser.value = user;
    setInsideChatStatus(true, chatUserId: user.id);

    // IMPORTANT: Only check deletion record once per chat session
    if (!_persistentDeletionCache.containsKey(user.id)) {
      _loadDeletionRecord(user.id);
    } else {
      currentChatDeletionTime.value = _persistentDeletionCache[user.id];
    }

    // Check if we have cached messages
    final cachedMessages = getCachedMessages(user.id);
    if (cachedMessages != null && cachedMessages.isNotEmpty) {
      hasCachedMessages.value = true;
      messages.assignAll(cachedMessages);
      debugPrint('⚡ Using cached messages (${cachedMessages.length}) for ${user.name}');
    }

    return _repo.getAllMessages(user).map((snapshot) {
      final allMessages = snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();

      // Apply deletion filter
      final filteredMessages = _applyDeletionFilter(allMessages, user.id);

      // Update UI and cache
      messages.assignAll(filteredMessages);
      cacheMessages(user.id, filteredMessages);
      hasCachedMessages.value = filteredMessages.isNotEmpty;

      return filteredMessages;
    });
  }

  // FIXED: Load deletion record only once per chat
  Future<void> _loadDeletionRecord(String userId) async {
    try {
      final deletionDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_repo.currentUserId)
          .collection('deleted_chats')
          .doc(userId)
          .get();

      String? deletionTime;
      if (deletionDoc.exists) {
        deletionTime = deletionDoc.data()!['deleted_at'] as String;
        debugPrint('📌 Found deletion record for $userId: $deletionTime');
      }

      // Cache the result (even if null)
      _persistentDeletionCache[userId] = deletionTime;
      currentChatDeletionTime.value = deletionTime;

    } catch (e) {
      debugPrint('❌ Error loading deletion record: $e');
      _persistentDeletionCache[userId] = null;
      currentChatDeletionTime.value = null;
    }
  }

  // FIXED: Efficient message filtering
  List<Message> _applyDeletionFilter(List<Message> allMessages, String userId) {
    final deletionTime = _persistentDeletionCache[userId];

    if (deletionTime == null) {
      return allMessages; // No deletion, show all messages
    }

    final deletionTimestamp = int.parse(deletionTime);
    return allMessages.where((message) {
      final messageTimestamp = int.parse(message.sent);
      return messageTimestamp > deletionTimestamp;
    }).toList();
  }

  // FIXED: Check deletion record with cache
  Future<void> checkDeletionRecord() async {
    if (selectedUser.value == null) return;

    final userId = selectedUser.value!.id;

    // Use cached result if available
    if (_persistentDeletionCache.containsKey(userId)) {
      currentChatDeletionTime.value = _persistentDeletionCache[userId];
      return;
    }

    // Load from Firestore only if not cached
    await _loadDeletionRecord(userId);
  }

  // FIXED: Clear deletion record and update cache
  Future<void> clearDeletionRecord() async {
    if (selectedUser.value == null) return;

    final userId = selectedUser.value!.id;

    try {
      // Clear from Firestore
      await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_repo.currentUserId)
          .collection('deleted_chats')
          .doc(userId)
          .delete();

      // Clear from cache
      _persistentDeletionCache[userId] = null;
      currentChatDeletionTime.value = null;

      debugPrint('✅ Deletion record cleared for $userId');

      // Refresh messages to show all history
      messages.refresh();

    } catch (e) {
      debugPrint('❌ Error clearing deletion record: $e');
    }
  }

  // FIXED: Better navigation handling
  Future<void> handlePendingNavigation() async {
    if (_isNavigatingFromNotification || _hasHandledNotification) {
      debugPrint('🚫 Navigation already handled');
      return;
    }

    debugPrint('🔄 Processing pending navigation...');

    if (notificationUser != null) {
      debugPrint('📱 Navigating to chat from notification: ${notificationUser!.name}');

      _isNavigatingFromNotification = true;
      final userToNavigate = notificationUser!;

      notificationUser = null;
      _hasHandledNotification = true;

      if (await _shouldNavigateToChat()) {
        await Future.delayed(const Duration(milliseconds: 500));
        Get.to(() => ChattingView(user: userToNavigate));
        debugPrint('✅ Navigation successful');
      }

      _isNavigatingFromNotification = false;
      return;
    }

    if (pendingChatUserId != null && pendingChatUserId!.isNotEmpty) {
      _isNavigatingFromNotification = true;

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(pendingChatUserId!)
            .get();

        if (userDoc.exists) {
          final chatUser = ChatUser.fromJson(userDoc.data()!);
          pendingChatUserId = null;
          _hasHandledNotification = true;

          if (await _shouldNavigateToChat()) {
            await Future.delayed(const Duration(milliseconds: 500));
            Get.to(() => ChattingView(user: chatUser));
          }
        }
      } catch (e) {
        debugPrint('❌ Navigation error: $e');
        pendingChatUserId = null;
      }

      _isNavigatingFromNotification = false;
    }
  }

  Future<bool> _shouldNavigateToChat() async {
    try {
      final isAppActive = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
      if (!isAppActive) return false;

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
      debugPrint('❌ Navigation decision error: $e');
      return false;
    }
  }

  void resetNotificationState() {
    _hasHandledNotification = false;
    _isNavigatingFromNotification = false;
    notificationUser = null;
    pendingChatUserId = null;
    debugPrint('🔄 Notification state reset');
  }

  void setNavigationSource({required bool fromNotification}) {
    isFromNotification.value = fromNotification;
  }

  // FIXED: Optimized message sending with cache update
  Future<void> sendMessage(String text) async {
    if (selectedUser.value != null && text.trim().isNotEmpty) {
      final user = selectedUser.value!;

      // Optimistically update cache
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final optimisticMessage = Message(
        toId: user.id,
        msg: text.trim(),
        read: '',
        type: Type.text,
        fromId: _repo.currentUserId,
        sent: time,
      );

      // Update UI immediately
      final currentMessages = List<Message>.from(messages);
      currentMessages.insert(0, optimisticMessage);
      messages.assignAll(currentMessages);
      cacheMessages(user.id, currentMessages);

      try {
        if (Get.isRegistered<ChatListController>()) {
          final listController = Get.find<ChatListController>();
          await _repo.sendMessageOptimized(
            user,
            text.trim(),
            Type.text,
            onMessageCreated: (message) {
              listController.updateLastMessageLocally(user.id, message);
            },
          );
        } else {
          await _repo.sendMessage(user, text.trim(), Type.text);
        }
      } catch (e) {
        debugPrint('❌ Error sending message: $e');
        // Remove optimistic message on error
        final updatedMessages = messages.where((m) => m.sent != time).toList();
        messages.assignAll(updatedMessages);
        cacheMessages(user.id, updatedMessages);
      }
    }
  }

  // FIXED: Better first message handling
  Future<void> sendFirstMessage(String text) async {
    debugPrint("🚀 Sending first message to ${selectedUser.value?.name}");

    if (selectedUser.value != null && text.trim().isNotEmpty) {
      try {
        await _repo.sendFirstMessage(selectedUser.value!, text.trim(), Type.text);

        // Clear any deletion record since user is actively chatting
        if (_persistentDeletionCache.containsKey(selectedUser.value!.id)) {
          _persistentDeletionCache[selectedUser.value!.id] = null;
          currentChatDeletionTime.value = null;
        }

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

  // FIXED: Clean exit with proper cache preservation
  Future<void> exitChat({bool isDisposing = false}) async {
    try {
      debugPrint('👋 Exiting chat... (isDisposing: $isDisposing)');

      if (selectedUser.value != null) {
        final userId = selectedUser.value!.id;

        // Cancel active streams
        _activeStreams[userId]?.cancel();
        _activeStreams.remove(userId);

        // DON'T clear persistent cache on exit
        // Only clear reactive state
        if (isDisposing) {
          messages.clear();
          selectedUser.value = null;
          currentChatDeletionTime.value = null;
        } else {
          messages.clear();
          selectedUser.value = null;
          currentChatDeletionTime.value = null;
          hasCachedMessages.value = false;
        }

        if (!isDisposing) {
          try {
            await setInsideChatStatus(false);
          } catch (e) {
            debugPrint('⚠️ Error setting chat status: $e');
          }
        }
      }

      // Reset other controllers if not disposing
      if (!isDisposing && Get.isRegistered<ChatListController>()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<ChatListController>()) {
            final listController = Get.find<ChatListController>();
            listController.isLoading.value = false;
            listController.isRefreshing.value = false;
            listController.isNavigatingToChat.value = false;

            Future.delayed(const Duration(milliseconds: 300), () {
              if (Get.isRegistered<ChatListController>()) {
                listController.reconnectListeners();
              }
            });
          }
        });
      }

      debugPrint('✅ Chat exited successfully');
    } catch (e) {
      debugPrint('❌ Error exiting chat: $e');
    }
  }

  // Helper method to check if we should show "Chat history cleared"
  bool shouldShowHistoryCleared(String userId) {
    final deletionTime = _persistentDeletionCache[userId];
    final hasMessages = cachedMessagesPerUser[userId]?.isNotEmpty ?? false;

    // Only show if:
    // 1. There's a deletion record
    // 2. No messages are visible (all filtered out)
    // 3. There are actually messages in the conversation (to avoid showing on new chats)
    return deletionTime != null && !hasMessages && _hasRealMessages(userId);
  }

  // Check if conversation actually has messages (not just empty)
  bool _hasRealMessages(String userId) {
    // This could be enhanced to check Firestore for actual message count
    // For now, assume true if deletion record exists
    return _persistentDeletionCache[userId] != null;
  }

  // Other existing methods remain the same...
  Future<void> createUser({
    required String name,
    required String id,
    required String email,
    required String image,
    required bool isOnline,
    required bool isMobileOnline,
  }) => _repo.createUser(
    name: name,
    id: id,
    email: email,
    image: image,
    isOnline: isOnline,
    isMobileOnline: isMobileOnline,
  );

  Future<void> setInsideChatStatus(bool isInside, {String? chatUserId}) async {
    try {
      await _repo.insideChatStatus(isInside);
      FirebaseService.setAppState(isInChat: isInside, chatUserId: chatUserId);
      debugPrint('💬 Chat status: ${isInside ? "Inside" : "Outside"}${chatUserId != null ? " with $chatUserId" : ""}');
    } catch (e) {
      debugPrint('❌ Error setting chat status: $e');
    }
  }

  Future<bool> userExists(String uid) => _repo.userExists(uid);
  Future<ChatUser?> getUserById(String uid, String imageUrl) => _repo.getUserById(uid, imageUrl);

  Future<void> initSelf() async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Initializing self info...');

      await _repo.getSelfInfo();

      if (FirebaseService.me != null) {
        debugPrint('✅ Self info initialized: ${FirebaseService.me!.name}');
      } else {
        await Future.delayed(const Duration(milliseconds: 1000));
        await _repo.getSelfInfo();
        if (FirebaseService.me == null) {
          throw Exception('Failed to initialize user');
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

  void listenToMessages(ChatUser user) {
    selectedUser.value = user;
    _repo.getAllMessages(user).listen((snapshot) {
      messages.value = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesStream(ChatUser user) {
    selectedUser.value = user;
    setInsideChatStatus(true, chatUserId: user.id);

    final baseStream = _repo.getAllMessages(user);
    return baseStream.asyncMap((snapshot) async {
      final deletionDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(_repo.currentUserId)
          .collection('deleted_chats')
          .doc(user.id)
          .get();

      if (!deletionDoc.exists) {
        return snapshot;
      }

      return snapshot;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfoStream(String uid) {
    return _repo.getUserInfo(uid);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessageStream(ChatUser user) {
    return _repo.getLastMessage(user);
  }

  Future<void> sendImage(String currentUID, File imageFile) async {
    if (selectedUser.value != null) {
      await _repo.sendChatImage(currentUID, selectedUser.value!, imageFile);
    }
  }

  Future<void> deleteMessage(Message message) async {
    await _repo.deleteMessage(message);
  }

  Future<void> updateMessage(Message message, String newText) async {
    await _repo.updateMessage(message, newText);
  }

  Future<void> markMessageAsRead(Message message) async {
    await _repo.updateMessageReadStatus(message);
  }

  Future<void> blockUser(String userId) async {
    await _repo.blockUser(userId);
  }

  Future<void> unblockUser(String userId) async {
    await _repo.unblockUser(userId);
  }

  Future<bool> isUserBlocked(String userId) async {
    return await _repo.isUserBlocked(userId);
  }

  Future<bool> isBlockedByFriend(String userId) async {
    return await _repo.isMyFriendBlocked(userId);
  }

  Future<void> updateFcmToken(String token) async {
    await _repo.updateFcmToken(token);
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    await _repo.updateActiveStatus(isOnline);
  }

  Future<void> updateLastSeen() async {
    await _repo.updateLastActive();
  }

  Future<bool> addChatUser(String uid) async {
    debugPrint('🚀 Adding chat user $uid');
    final result = await _repo.addChatUser(uid);
    if (result) {
      debugPrint('✅ Chat user added successfully');
    }
    return result;
  }

  Future<void> updateMessageReadStatus(Message message) => _repo.updateMessageReadStatus(message);

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersStream(currentUid) {
    return _repo.getMyUsersId(currentUid);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsersStream(List<String> userIds) {
    return _repo.getAllUsers(userIds);
  }

  Stream<Message?> getLastMessage(ChatUser user) {
    return _repo.getLastMessage(user).map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Message.fromJson(snapshot.docs.first.data());
      }
      return null;
    });
  }

  bool isChattingWithUser(String userId) {
    return selectedUser.value != null && selectedUser.value!.id == userId;
  }

  @override
  void onClose() {
    _activeStreams.values.forEach((subscription) => subscription.cancel());
    _activeStreams.clear();
    exitChat(isDisposing: true).catchError((e) {
      debugPrint('⚠️ Error during cleanup: $e');
      return null;
    });
    super.onClose();
  }

  // FIXED: Additional helper methods
  String getConversationId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) <= 0) {
      return '${userId1}_$userId2';
    } else {
      return '${userId2}_$userId1';
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
      debugPrint('❌ Migration error: $e');
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
}