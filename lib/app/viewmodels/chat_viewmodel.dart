// chat_viewmodel.dart - Fixed cache management and deletion handling

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../core/export.dart';
import '../core/services/env_config_service.dart';
import '../core/services/firebase_service/export.dart';
import '../core/services/hive_message_service.dart';
import '../data/repositories/chat_repository.dart';
import 'dart:io';
import '../views/chat/chatting_view.dart';
import '../views/chat/export.dart';
import 'chat_list_viewmodel.dart';

class ChatViewModel extends GetxController with WidgetsBindingObserver {
  // Hive service for persistent storage
  final _hiveService = HiveMessageService();
  
  // Deduplication tracking for Hive saves
  final Map<String, ({int messageCount, DateTime timestamp})> _lastHiveSave = {};
  
  // PERFORMANCE: Track recently marked messages to prevent duplicate marking
  final Set<String> _recentlyMarkedAsRead = {};
  Timer? _markAsReadCleanupTimer;
  
  // FIXED: Persistent cache that survives app restarts
  final RxBool isOtherUserTyping = false.obs;
  StreamSubscription? _typingStatusSubscription;
// Start listening to typing status
  void listenToTypingStatus(String otherUserId) {
    _typingStatusSubscription?.cancel();

    _typingStatusSubscription = _repo
        .getTypingStatusStream(otherUserId)
        .listen((status) {
      isOtherUserTyping.value = status['is_typing'] as bool;
    });
  }

  // Handle current user typing
  void handleTyping() {
    if (selectedUser.value != null) {
      _repo.handleTyping(selectedUser.value!.id);
    }
  }

  // Stop typing
  void stopTyping() {
    if (selectedUser.value != null) {
      _repo.stopTyping(selectedUser.value!.id);
    }
  }

  // Clean up typing status
  void cleanupTypingStatus() {
    if (selectedUser.value != null) {
      _repo.cleanupTypingStatus(selectedUser.value!.id);
    }
  }
  static final Map<String, List<Message>> _persistentMessageCache = {};
  static final Map<String, String?> _persistentDeletionCache = {};
  static final Map<String, StreamSubscription> _activeStreams = {};
  // Observable for tracking current sending message status
  final currentMessageStatus = MessageStatus.pending.obs;
  final ChatRepository _repo = ChatRepository();
  ChatRepository get chatRepo => _repo; // Expose for batch operations
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

    // Add lifecycle observer to handle app state changes
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  // FIXED: Handle app lifecycle state changes for proper delivery confirmation
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('📱 App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
  // FIXED: Handle app resuming - mark pending messages as delivered
  void _handleAppResumed() async {
    debugPrint('🔄 App resumed - checking for undelivered messages');

    try {
      // Mark any pending messages as delivered when app comes to foreground
      if (selectedUser.value != null) {
        await _markIncomingMessagesAsDelivered(selectedUser.value!.id);
      }

      // Update online status
      await _repo.updateActiveStatus(true);

    } catch (e) {
      debugPrint('❌ Error handling app resume: $e');
    }
  }

  void _handleAppPaused() {
    debugPrint('⏸️ App paused');
    // App going to background - nothing specific needed here
  }
  // Send view-once image
  Future<void> sendViewOnceImage(String currentUID, File imageFile) async {
    if (selectedUser.value != null) {
      await _repo.sendViewOnceChatImage(currentUID, selectedUser.value!, imageFile);
    }
  }
// Add these methods to ChatViewModel class as well
  Future<void> addMessageReaction(Message message, String reaction) async {
    await _repo.addReactionToMessage(message, reaction);
  }

  Future<void> removeMessageReaction(Message message) async {
    await _repo.removeReactionFromMessage(message);
  }
  // Mark view-once image as viewed and delete it
  Future<void> markViewOnceAsViewed(Message message) async {
    try {

      // Update message as viewed in Firestore
      await _repo.markViewOnceAsViewed(message);

      // Delete the image from storage after a short delay
      await Future.delayed(const Duration(seconds: 10));
      await _repo.deleteViewOnceImage(message);

      // Update local cache
      final index = messages.indexWhere((m) => m.sent == message.sent);
      if (index != -1) {
        messages[index] = Message(
          toId: message.toId,
          msg: 'Photo was viewed', // Replace with viewed message
          read: message.read,
          type: Type.text,
          fromId: message.fromId,
          sent: message.sent,
          isViewOnce: true,
          isViewed: true,
        );
        messages.refresh();
        await  _clearImageFromCache(message.msg);
        // Also update cached messages
        if (selectedUser.value != null) {
          cachedMessagesPerUser[selectedUser.value!.id] = List.from(messages);
        }
      }

      debugPrint('✅ View-once image marked as viewed');


    } catch (e) {
      debugPrint('Error marking view-once as viewed: $e');
    }
  }
  // Clear image from all caches
_clearImageFromCache(String imageUrl) {
    try {
      // Clear from CachedNetworkImage cache
      CachedNetworkImage.evictFromCache(imageUrl);

      // Clear from memory cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      debugPrint('✅ Cleared image from cache');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  // FIXED: Initialize persistent cache on app start
  void _initializePersistentCache() async {
    // Hive will automatically load data when boxes are opened
    // No need to manually load data here
    debugPrint('📦 Hive-based persistent cache ready');
  }

  // FIXED: Smart cache retrieval from Hive
  Future<List<Message>?> getCachedMessages(String userId) async {
    // First check reactive cache
    if (cachedMessagesPerUser.containsKey(userId)) {
      return cachedMessagesPerUser[userId];
    }

    // Then load from Hive
    final hiveMessages = await _hiveService.getMessages(userId);
    if (hiveMessages.isNotEmpty) {
      cachedMessagesPerUser[userId] = hiveMessages;
      return hiveMessages;
    }

    return null;
  }

  // FIXED: Professional cache management with Hive (Incremental saves)
  Future<void> cacheMessages(String userId, List<Message> messages) async {
    // Update reactive cache (always update memory)
    cachedMessagesPerUser[userId] = messages;
    
    // PERFORMANCE: Throttle Hive saves (500ms cooldown)
    // Note: HiveMessageService now does incremental saves internally
    // So we only throttle the frequency, not the content
    final now = DateTime.now();
    final lastSave = _lastHiveSave[userId];
    
    if (lastSave != null && 
        now.difference(lastSave.timestamp).inMilliseconds < 500) {
      debugPrint('⏭️ Throttled Hive save for user $userId (${now.difference(lastSave.timestamp).inMilliseconds}ms since last save)');
      return;
    }
    
    // Save to Hive (incremental - only new/changed messages saved internally)
    await _hiveService.saveMessages(userId, messages);
    
    // Track this save
    _lastHiveSave[userId] = (messageCount: messages.length, timestamp: now);

    debugPrint('✅ Cache sync complete for user $userId (${messages.length} total messages)');
  }

  // FIXED: Optimized message stream with proper cache handling
  Future<Stream<List<Message>>> getFilteredMessagesStream(ChatUser user) async {
    selectedUser.value = user;
    debugPrint('📌 Setting selected user in stream: ${user.name} (${user.id})');

    setInsideChatStatus(true, chatUserId: user.id);
    // Mark all pending messages as delivered when entering chat
    _markIncomingMessagesAsDelivered(user.id);
    // IMPORTANT: Only check deletion record once per chat session
    if (!_persistentDeletionCache.containsKey(user.id)) {
      _loadDeletionRecord(user.id);
    } else {
      currentChatDeletionTime.value = _persistentDeletionCache[user.id];
    }

    // Check if we have cached messages from Hive
    final cachedMessages = await getCachedMessages(user.id);
    if (cachedMessages != null && cachedMessages.isNotEmpty) {
      hasCachedMessages.value = true;
      messages.assignAll(cachedMessages);
      debugPrint('⚡ Using cached messages from Hive (${cachedMessages.length}) for ${user.name}');
    }

    return _repo.getAllMessages(user).asyncMap((snapshot) async {
      final allMessages = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final message = Message.fromJson(data);
            
            // Ensure status is properly set from Firestore data
            if (data['status'] != null) {
              try {
                message.status = MessageStatus.values.firstWhere(
                  (e) => e.name == data['status'],
                  orElse: () {
                    // Fallback to determining status from timestamps
                    if (data['read'] != null && data['read'].toString().isNotEmpty) {
                      return MessageStatus.read;
                    } else if (data['delivered'] != null && data['delivered'].toString().isNotEmpty) {
                      return MessageStatus.delivered;
                    } else {
                      return MessageStatus.sent;
                    }
                  },
                );
              } catch (e) {
                debugPrint('⚠️ Error parsing status: $e');
              }
            }
            
            return message;
          })
          .toList();
      // Mark new incoming messages as delivered
      processMessageStatuses(allMessages, user.id);
      // Apply deletion filter
      final filteredMessages = _applyDeletionFilter(allMessages, user.id);

      // Update UI and cache
      messages.assignAll(filteredMessages);
      await cacheMessages(user.id, filteredMessages);
      hasCachedMessages.value = filteredMessages.isNotEmpty;

      return filteredMessages;
    });
  }
  // Process and mark incoming messages as delivered
  // Process message statuses properly
  void processMessageStatuses(List<Message> messages, String chatUserId) {
    final currentUserId = _repo.currentUserId;

    for (var message in messages) {
      // For incoming messages - confirm delivery
      if (message.toId == currentUserId &&
          message.fromId == chatUserId &&
          message.delivered!.isEmpty) {
        // Mark as delivered in background
        _repo.confirmMessageDelivery(chatUserId, message.sent);
      }
    }
  }
  // Mark message as read when user views it
  // Future<void> markMessageAsRead(Message message) async {
  //   try {
  //     // Don't mark our own messages as read
  //     if (message.fromId == _repo.currentUserId) return;
  //
  //     // Don't re-mark if already read
  //     if (message.read.isNotEmpty) return;
  //
  //     // Update in Firestore
  //     await _repo.markMessageAsRead(message.fromId, message.sent);
  //
  //     // Update local message
  //     final index = messages.indexWhere((m) => m.sent == message.sent);
  //     if (index != -1) {
  //       messages[index].read = DateTime.now().millisecondsSinceEpoch.toString();
  //       messages[index].status = MessageStatus.read;
  //       messages.refresh();
  //
  //       // Update cache
  //       if (selectedUser.value != null) {
  //         cachedMessagesPerUser[selectedUser.value!.id] = List.from(messages);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Error marking message as read: $e');
  //   }
  // }

  // Confirm delivery for a specific message
  // Future<void> _confirmDeliveryForMessage(Message message) async {
  //   try {
  //     await _repo.confirmMessageDelivery(message.fromId, message.sent);
  //     debugPrint('✅ Confirmed delivery for message: ${message.sent}');
  //   } catch (e) {
  //     debugPrint('❌ Error confirming delivery: $e');
  //   }
  // }

  // Mark all incoming messages as delivered when entering chat
  Future<void> _markIncomingMessagesAsDelivered(String senderId) async {
    try {
      await _repo.markMessagesAsDelivered(senderId);
      debugPrint('✅ Marked all incoming messages as delivered');
    } catch (e) {
      debugPrint('❌ Error marking messages as delivered: $e');
    }
  }

  // FIXED: Load deletion record from Hive and Firestore
  Future<void> _loadDeletionRecord(String userId) async {
    try {
      // First check Hive for locally stored deletion time
      String? deletionTime = await _hiveService.getDeletionTime(userId);
      
      // If not in Hive, check Firestore
      if (deletionTime == null) {
        final deletionDoc = await FirebaseFirestore.instance
            .collection(EnvConfig.firebaseUsersCollection)
            .doc(_repo.currentUserId)
            .collection('deleted_chats')
            .doc(userId)
            .get();

        if (deletionDoc.exists) {
          deletionTime = deletionDoc.data()!['deleted_at'] as String;
          // Store in Hive for future access
          await _hiveService.saveDeletionTime(userId, deletionTime);
          debugPrint('📌 Found deletion record for $userId: $deletionTime');
        }
      } else {
        debugPrint('📌 Loaded deletion record from Hive for $userId: $deletionTime');
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

  // PUBLIC: Load deletion record for a specific user (used before showing cached messages)
  Future<void> loadDeletionRecordForUser(String userId) async {
    // Use cached result if available
    if (_persistentDeletionCache.containsKey(userId)) {
      currentChatDeletionTime.value = _persistentDeletionCache[userId];
      return;
    }
    // Load from Firestore/Hive
    await _loadDeletionRecord(userId);
  }

  // PUBLIC: Apply deletion filter to messages (used for filtering cached messages)
  List<Message> applyDeletionFilterToMessages(List<Message> messages, String userId) {
    return _applyDeletionFilter(messages, userId);
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

  // FIXED: Clear deletion record from Hive, Firestore and cache
  Future<void> clearDeletionRecord() async {
    if (selectedUser.value == null) return;

    final userId = selectedUser.value!.id;

    try {
      // Clear from Firestore
      await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(_repo.currentUserId)
          .collection('deleted_chats')
          .doc(userId)
          .delete();

      // Clear from Hive
      await _hiveService.clearDeletionTime(userId);

      // Clear from memory cache
      _persistentDeletionCache[userId] = null;
      currentChatDeletionTime.value = null;

      debugPrint('✅ Deletion record cleared for $userId (Firestore + Hive)');

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
            .collection(EnvConfig.firebaseUsersCollection)
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
  // FIXED: Better message sending with proper error handling
  // FIXED: Better message sending with validation
  Future<void> sendMessage(String text) async {
    if (selectedUser.value == null || text.trim().isEmpty) return;

    final user = selectedUser.value!;
    debugPrint('📤 Sending message to ${user.name}: $text');

    // Create optimistic message with pending status
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticMessage = Message(
      toId: user.id,
      msg: text.trim(),
      read: '',
      type: Type.text,
      fromId: _repo.currentUserId,
      sent: time,
      status: MessageStatus.pending, // Start with pending
    );

    // Update UI immediately
    final currentMessages = List<Message>.from(messages);
    currentMessages.insert(0, optimisticMessage);
    messages.assignAll(currentMessages);
    await cacheMessages(user.id, currentMessages);

    try {
      await _repo.sendMessageWithStatus(
        user,
        text.trim(),
        Type.text,
        messageId: time, // Pass the same ID used for optimistic message
        onMessageCreated: (message) {
          debugPrint('✅ Message created with status: ${message.status}');
        },
        onStatusUpdate: (status) async {
          // Update the message status in the list
          final index = messages.indexWhere((m) => m.sent == time);
          if (index != -1) {
            final oldMessage = messages[index];
            // Create new message object with updated status
            final updatedMessage = Message(
              toId: oldMessage.toId,
              msg: oldMessage.msg,
              read: oldMessage.read,
              type: oldMessage.type,
              fromId: oldMessage.fromId,
              sent: oldMessage.sent,
              status: status,
              delivered: status == MessageStatus.delivered || status == MessageStatus.read
                  ? DateTime.now().millisecondsSinceEpoch.toString()
                  : oldMessage.delivered,
              isViewOnce: oldMessage.isViewOnce,
              isViewed: oldMessage.isViewed,
              reactions: oldMessage.reactions,
            );
            
            // Replace with new object to trigger reactive update
            final updatedMessages = List<Message>.from(messages);
            updatedMessages[index] = updatedMessage;
            messages.assignAll(updatedMessages);
            
            // Update cache
            if (selectedUser.value != null) {
              await cacheMessages(selectedUser.value!.id, updatedMessages);
            }
          }
          debugPrint('📊 Message status updated to: $status');
        },
      );

      debugPrint('✅ Message sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending message: $e');

      // Update status to failed
      final index = messages.indexWhere((m) => m.sent == time);
      if (index != -1) {
        final oldMessage = messages[index];
        final failedMessage = Message(
          toId: oldMessage.toId,
          msg: oldMessage.msg,
          read: oldMessage.read,
          type: oldMessage.type,
          fromId: oldMessage.fromId,
          sent: oldMessage.sent,
          status: MessageStatus.failed,
          delivered: oldMessage.delivered,
          isViewOnce: oldMessage.isViewOnce,
          isViewed: oldMessage.isViewed,
          reactions: oldMessage.reactions,
        );
        
        final updatedMessages = List<Message>.from(messages);
        updatedMessages[index] = failedMessage;
        messages.assignAll(updatedMessages);
        
        if (selectedUser.value != null) {
          await cacheMessages(selectedUser.value!.id, updatedMessages);
        }
      }

      rethrow;
    }
  }

  // Mark messages as delivered when entering chat
  Future<void> markIncomingMessagesAsDelivered() async {
    if (selectedUser.value == null) return;

    try {
      await _repo.markMessagesAsDelivered(selectedUser.value!.id);
    } catch (e) {
      debugPrint('Error marking messages as delivered: $e');
    }
  }


  // FIXED: Better first message handling with status tracking
  Future<void> sendFirstMessage(String text, {String? profileIdForConnects}) async {
    if (selectedUser.value == null) {
      debugPrint('❌ ERROR: No selected user for first message');
      throw Exception('Selected user not set');
    }

    final user = selectedUser.value!;
    debugPrint("🚀 Sending first message to ${user.name} (${user.id})");

    if (text.trim().isEmpty) {
      debugPrint('⚠️ Empty first message text');
      return;
    }

    // Create optimistic message with pending status
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticMessage = Message(
      toId: user.id,
      msg: text.trim(),
      read: '',
      type: Type.text,
      fromId: _repo.currentUserId,
      sent: time,
      status: MessageStatus.pending,
    );

    // Add to UI immediately
    final currentMessages = List<Message>.from(messages);
    currentMessages.insert(0, optimisticMessage);
    messages.assignAll(currentMessages);
    await cacheMessages(user.id, currentMessages);

    try {
      // Send the first message with status tracking
      await _repo.sendFirstMessageWithStatus(
        user,
        text.trim(),
        Type.text,
        messageId: time,
        profileIdForConnects: profileIdForConnects,
        onStatusUpdate: (status) async {
          // Update the message status in the list
          final index = messages.indexWhere((m) => m.sent == time);
          if (index != -1) {
            final oldMessage = messages[index];
            final updatedMessage = Message(
              toId: oldMessage.toId,
              msg: oldMessage.msg,
              read: oldMessage.read,
              type: oldMessage.type,
              fromId: oldMessage.fromId,
              sent: oldMessage.sent,
              status: status,
              delivered: status == MessageStatus.delivered || status == MessageStatus.read
                  ? DateTime.now().millisecondsSinceEpoch.toString()
                  : oldMessage.delivered,
              isViewOnce: oldMessage.isViewOnce,
              isViewed: oldMessage.isViewed,
              reactions: oldMessage.reactions,
            );
            
            // Replace with new object to trigger reactive update
            final updatedMessages = List<Message>.from(messages);
            updatedMessages[index] = updatedMessage;
            messages.assignAll(updatedMessages);
            
            // Update cache
            if (selectedUser.value != null) {
              await cacheMessages(selectedUser.value!.id, updatedMessages);
            }
          }
          debugPrint('📊 First message status updated to: $status');
        },
      );

      // Clear any deletion record since user is actively chatting
      if (_persistentDeletionCache.containsKey(user.id)) {
        _persistentDeletionCache[user.id] = null;
        currentChatDeletionTime.value = null;
      }

      debugPrint("✅ First message sent successfully to ${user.name}");
    } catch (e) {
      debugPrint("❌ Error sending first message: $e");

      // Update status to failed
      final index = messages.indexWhere((m) => m.sent == time);
      if (index != -1) {
        final oldMessage = messages[index];
        final failedMessage = Message(
          toId: oldMessage.toId,
          msg: oldMessage.msg,
          read: oldMessage.read,
          type: oldMessage.type,
          fromId: oldMessage.fromId,
          sent: oldMessage.sent,
          status: MessageStatus.failed,
          delivered: oldMessage.delivered,
          isViewOnce: oldMessage.isViewOnce,
          isViewed: oldMessage.isViewed,
          reactions: oldMessage.reactions,
        );
        
        final updatedMessages = List<Message>.from(messages);
        updatedMessages[index] = failedMessage;
        messages.assignAll(updatedMessages);
        
        if (selectedUser.value != null) {
          await cacheMessages(selectedUser.value!.id, updatedMessages);
        }
      }

      // Show error to user
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Rethrow for handling in UI
      rethrow;
    }}

  // Helper method to verify and set selected user
  void ensureUserSelected(ChatUser user) {
    if (selectedUser.value?.id != user.id) {
      debugPrint('📌 Updating selected user to: ${user.name} (${user.id})');
      selectedUser.value = user;
    }
  }



  // FIXED: Clean exit with proper cache preservation
  // / FIXED: Clean exit without disrupting chat list
  Future<void> exitChat({bool isDisposing = false}) async {
    try {
      debugPrint('👋 Exiting chat... (isDisposing: $isDisposing)');

      if (selectedUser.value != null) {
        final userId = selectedUser.value!.id;

        // Cancel active streams for this chat only
        _activeStreams[userId]?.cancel();
        _activeStreams.remove(userId);

        // Clear chat-specific state
        messages.clear();
        selectedUser.value = null;
        // currentChatUserId = null;    // IMPORTANT: Clear current chat user ID

        currentChatDeletionTime.value = null;
        hasCachedMessages.value = false;

        // Update chat status
        if (!isDisposing) {
          try {
            await setInsideChatStatus(false);
          } catch (e) {
            debugPrint('⚠️ Error setting chat status: $e');
          }
        }
      } else {
        // Even if selectedUser is null, clear everything
        messages.clear();
       // currentChatUserId = null;
        currentChatDeletionTime.value = null;
        hasCachedMessages.value = false;

        if (!isDisposing) {
          await setInsideChatStatus(false);
        }
      }

      // FIXED: Don't reset ChatListController when just navigating back
      if (!isDisposing && Get.isRegistered<ChatListController>()) {
        // Small delay to ensure smooth transition
        await Future.delayed(const Duration(milliseconds: 100));

        final listController = Get.find<ChatListController>();

        // Only reconnect if not already loading
        if (!listController.isLoading.value && !listController.isRefreshing.value) {
          listController.ensureStreamsActive();
        }
      }

      debugPrint('✅ Chat exited successfully - selectedUser: ${selectedUser.value?.id}, currentChatUserId: $currentChatUserId');
    } catch (e) {
      debugPrint('❌ Error exiting chat: $e');
    }
  }

  // CRITICAL: Clear Hive cache for a specific user (called when chat is deleted)
  Future<void> clearHiveCacheForUser(String userId) async {
    try {
      await _hiveService.clearMessages(userId);
      await _hiveService.saveDeletionTime(userId, DateTime.now().millisecondsSinceEpoch.toString());
      _persistentDeletionCache[userId] = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint('🧹 Cleared Hive cache for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing Hive cache: $e');
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
          .collection(EnvConfig.firebaseUsersCollection)
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
  // PERFORMANCE: Public method to mark messages as recently marked (for batch operations)
  void markAsRecentlyMarked(String messageId) {
    _recentlyMarkedAsRead.add(messageId);
    
    // Auto-cleanup after 3 seconds
    _markAsReadCleanupTimer?.cancel();
    _markAsReadCleanupTimer = Timer(const Duration(seconds: 3), () {
      _recentlyMarkedAsRead.clear();
    });
  }

// Enhanced mark as read with sync
  @override
  Future<void> markMessageAsRead(Message message) async {
    try {
      if (message.fromId == _repo.currentUserId) return;
      if (message.read.isNotEmpty) return;
      
      // PERFORMANCE: Prevent duplicate marking within 3 seconds
      if (_recentlyMarkedAsRead.contains(message.sent)) {
        debugPrint('⏭️ Skipped duplicate mark-as-read for message ${message.sent} (already marked recently)');
        return;
      }
      
      // Track this message as recently marked
      markAsRecentlyMarked(message.sent);

      // Mark as read in repository
      await _repo.markMessageAsRead(message.fromId, message.sent);

      // Sync the state
      await _repo.syncMessageState(message, MessageStatus.read);

      // Update local
      final index = messages.indexWhere((m) => m.sent == message.sent);
      if (index != -1) {
        messages[index].read = DateTime.now().millisecondsSinceEpoch.toString();
        messages[index].status = MessageStatus.read;
        messages.refresh();

        if (selectedUser.value != null) {
          cachedMessagesPerUser[selectedUser.value!.id] = List.from(messages);
        }
      }

      // Notify chat list
      if (Get.isRegistered<ChatListController>()) {
        final listController = Get.find<ChatListController>();
        listController.updateMessageStatus(message.fromId, message.sent, MessageStatus.read);
      }

    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
    }
  }
  @override
  Future<void> deleteMessage(Message message) async {
    try {
      // Use the enhanced delete method
      await _repo.deleteMessageWithSync(message);

      // Remove from local list
      messages.removeWhere((m) => m.sent == message.sent);
      messages.refresh();

      // Update cache
      if (selectedUser.value != null) {
        cachedMessagesPerUser[selectedUser.value!.id] = List.from(messages);
        _persistentMessageCache[selectedUser.value!.id] = List.from(messages);
      }

      // Force refresh in chat list
      if (Get.isRegistered<ChatListController>()) {
        final listController = Get.find<ChatListController>();
        await listController.refreshSpecificUser(message.fromId == _repo.currentUserId
            ? message.toId
            : message.fromId);
      }

    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      rethrow;
    }
  }

  Future<void> updateMessage(Message message, String newText) async {
    await _repo.updateMessage(message, newText);
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
    try {
      debugPrint('📝 Adding chat user: $uid');
      final result = await _repo.addChatUser(uid);
      debugPrint('✅ Chat user added: $result');
      
      // Refresh chat list if user was added successfully
      if (result && Get.isRegistered<ChatListController>()) {
        final chatListController = Get.find<ChatListController>();
        // Force refresh the chat list to show new user
        await Future.delayed(const Duration(milliseconds: 500));
        chatListController.forceRefresh();
        debugPrint('🔄 Chat list refreshed after adding new user');
      }
      
      return result;
    } catch (e) {
      debugPrint('❌ Error adding chat user: $e');
      return false;
    }
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
// Helper to clear navigation state
//   void clearNavigationState() {
//     selectedUser.value = null;
//     currentChatUserId = null;
//     messages.clear();
//     debugPrint('🧹 Navigation state cleared');
//   }
// FIXED: More reliable check for current chat
  // FIXED: More accurate check for current chat
  bool isChattingWithUser(String userId) {
    // Only return true if we're actually in a chat view
    final currentRoute = Get.currentRoute;
    final isInChatView = currentRoute.contains('/chatting_view/') ||
        currentRoute.contains('/ChattingView') ||
        currentRoute == '/chatting-view';

    if (!isInChatView) {
      debugPrint('❌ Not in chat view, current route: $currentRoute');
      return false;
    }

    // Check if we're chatting with this specific user
    if (selectedUser.value != null && selectedUser.value!.id == userId) {
      debugPrint('✅ Already chatting with user: $userId');
      return true;
    }

    if (currentChatUserId == userId) {
      debugPrint('✅ User ID matches current chat context: $userId');
      return true;
    }

    return false;
  }

  // Helper to force clear all chat state
 forceClearChatState() {
    debugPrint('🧹 Force clearing all chat state');
    selectedUser.value = null;
    // currentChatUserId = null;
    messages.clear();
    currentChatDeletionTime.value = null;
    hasCachedMessages.value = false;
  }

  @override
  void onClose() {
    for (var subscription in _activeStreams.values) {
      subscription.cancel();
    }
    _activeStreams.clear();
    _typingStatusSubscription?.cancel();
    cleanupTypingStatus();
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
          .collection(EnvConfig.firebaseChatsCollection)
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
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(currentUserId)
          .collection('my_users')
          .get();

      for (var userDoc in myUsersSnapshot.docs) {
        final otherUserId = userDoc.id;
        final data = userDoc.data();

        if (data['last_message_time'] == null) {
          final chatId = getConversationId(currentUserId, otherUserId);
          final lastMessageSnapshot = await FirebaseFirestore.instance
              .collection(EnvConfig.firebaseChatsCollection)
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
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(userId)
          .update({
        'last_message': lastMessageTime,
      });
    } catch (e) {
      debugPrint('Error updating last message time: $e');
    }
  }
}