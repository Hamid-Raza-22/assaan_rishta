// // ChattingViewController - Clean Business Logic Layer
// // Manages all chat state, messaging, and user interactions
//
// import 'dart:async';
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// import '../../core/export.dart';
// import '../../core/routes/app_routes.dart';
// import '../../domain/export.dart';
// import '../../utils/exports.dart';
// import '../../viewmodels/chat_viewmodel.dart';
// import '../../viewmodels/chat_list_viewmodel.dart';
//
// class ChattingViewController extends GetxController with WidgetsBindingObserver {
//   // ========== Constructor Parameters ==========
//   final ChatUser user;
//   final bool? initialBlockedStatus;
//   final bool? initialBlockedByOtherStatus;
//   final bool? initialDeletedStatus;
//
//   ChattingViewController({
//     required this.user,
//     this.initialBlockedStatus,
//     this.initialBlockedByOtherStatus,
//     this.initialDeletedStatus,
//   });
//
//   // ========== Dependencies ==========
//   final useCase = Get.find<UserManagementUseCase>();
//   final chatController = Get.find<ChatViewModel>();
//   final chatListController = Get.find<ChatListController>();
//
//   // ========== Controllers ==========
//   late TextEditingController textController;
//   late ScrollController scrollController;
//
//   // ========== Observable State ==========
//   var profileDetails = CurrentUserProfile().obs;
//   final currentUserProfile = Rx<String?>(null);
//   final currentUserImageUrl = ''.obs;
//   final cachedMessages = <Message>[].obs;
//   final cachedUserData = Rx<ChatUser?>(null);
//
//   // UI States
//   final showEmoji = false.obs;
//   final uploading = false.obs;
//   final paused = false.obs;
//   final isInitialLoading = true.obs;
//   final showLoading = false.obs;
//   final isKeyboardVisible = false.obs;
//
//   // Block & Delete Status
//   late final RxBool isBlocked;
//   late final RxBool isBlockedByOther;
//   late final RxBool isDelete;
//
//   // Message Selection
//   final isSelectionMode = false.obs;
//   final selectedMessages = <Message>[].obs;
//
//   // Reply Feature
//   final replyingTo = Rxn<Message>();
//   final replyPreview = ''.obs;
//
//   // Typing Status
//   final RxBool isOtherUserTyping = false.obs;
//
//   // ========== Internal State ==========
//   String currentUID = "";
//   bool _isDisposed = false;
//   bool _isActiveController = false;
//   String? _currentChatUserId;
//
//   // ========== Stream Subscriptions ==========
//   StreamSubscription<List<Message>>? _messagesSubscription;
//   StreamSubscription? _userStreamSubscription;
//   StreamSubscription? _statusUpdateSubscription;
//   StreamSubscription? _typingStatusSubscription;
//   Timer? _typingDebounceTimer;
//
//   // ========== Lifecycle Methods ==========
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeController();
//   }
//
//   void _initializeController() {
//     debugPrint('🚀 Initializing ChattingViewController for ${user.name}');
//
//     // Initialize controllers
//     scrollController = ScrollController();
//     textController = TextEditingController();
//     textController.addListener(_onTextChanged);
//
//     // Setup state
//     _isDisposed = false;
//     currentUID = useCase.getUserId().toString();
//     _currentChatUserId = user.id;
//     _isActiveController = true;
//
//     // Initialize block status
//     isBlocked = (initialBlockedStatus ?? false).obs;
//     isBlockedByOther = (initialBlockedByOtherStatus ?? false).obs;
//     isDelete = (initialDeletedStatus ?? false).obs;
//
//     // Setup observers
//     WidgetsBinding.instance.addObserver(this);
//
//     // Initialize features
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _listenToKeyboardVisibility();
//       _precacheAvatars();
//     });
//
//     // Fetch user profile
//     _fetchCurrentUserProfile();
//
//     // Start listening
//     _listenToTypingStatus();
//     _markMessagesAsDeliveredOnEntry();
//     _initializeChat();
//
//     debugPrint('✅ ChattingViewController initialized');
//   }
//
//   @override
//   void onClose() {
//     debugPrint('🗑️ Closing ChattingViewController for ${user.name}');
//
//     // Mark as inactive
//     _isActiveController = false;
//     _currentChatUserId = null;
//
//     // Cancel subscriptions
//     _statusUpdateSubscription?.cancel();
//     _messagesSubscription?.cancel();
//     _userStreamSubscription?.cancel();
//     _typingStatusSubscription?.cancel();
//     _typingDebounceTimer?.cancel();
//
//     _messagesSubscription = null;
//     _userStreamSubscription = null;
//
//     // Stop typing
//     _stopTyping();
//
//     // Remove listeners
//     textController.removeListener(_onTextChanged);
//
//     // Clear chat state
//     if (chatController.selectedUser.value?.id == user.id) {
//       chatController.exitChat();
//     }
//
//     chatController.forceClearChatState();
//     chatController.setInsideChatStatus(false);
//
//     // Ensure chat list is active
//     if (Get.isRegistered<ChatListController>()) {
//       final listController = Get.find<ChatListController>();
//       Future.delayed(const Duration(milliseconds: 200), () {
//         listController.ensureStreamsActive();
//       });
//     }
//
//     // Remove observer
//     WidgetsBinding.instance.removeObserver(this);
//
//     // Dispose controllers
//     if (!_isDisposed) {
//       scrollController.dispose();
//       textController.dispose();
//       _isDisposed = true;
//     }
//
//     super.onClose();
//     debugPrint('✅ ChattingViewController disposed');
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_isActiveController) return;
//
//     switch (state) {
//       case AppLifecycleState.resumed:
//         if (_currentChatUserId == user.id && _isActiveController) {
//           chatController.setInsideChatStatus(true, chatUserId: user.id);
//           paused.value = false;
//
//           if (chatController.selectedUser.value?.id == user.id) {
//             chatController.markIncomingMessagesAsDelivered();
//             _markMessagesAsRead(cachedMessages);
//           }
//         }
//         break;
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.detached:
//       case AppLifecycleState.hidden:
//         if (_isActiveController) {
//           chatController.setInsideChatStatus(false);
//           paused.value = true;
//         }
//         break;
//     }
//   }
//
//   // ========== Initialization Methods ==========
//   Future<void> _initializeChat() async {
//     debugPrint('📱 Initializing chat for ${user.name}');
//
//     // Set selected user
//     chatController.selectedUser.value = user;
//     debugPrint('✅ Selected user set to: ${user.name} (${user.id})');
//
//     // Load cached messages if available
//     if (chatController.cachedMessagesPerUser.containsKey(user.id)) {
//       cachedMessages.value = chatController.cachedMessagesPerUser[user.id]!;
//     }
//
//     // Set chat status
//     chatController.setInsideChatStatus(true, chatUserId: user.id);
//     chatController.checkDeletionRecord();
//
//     // Mark messages as delivered
//     await chatController.markIncomingMessagesAsDelivered();
//
//     // Start listeners
//     _listenForStatusUpdates();
//     _updateBlockStatus();
//     _initializeMessagesStream();
//     _initializeUserStream();
//   }
//
//   Future<void> _updateBlockStatus() async {
//     try {
//       final results = await Future.wait([
//         chatController.isUserBlocked(user.id),
//         chatController.isBlockedByFriend(user.id),
//       ]);
//
//       isBlocked.value = results[0];
//       isBlockedByOther.value = results[1];
//     } catch (e) {
//       debugPrint('Error checking block status: $e');
//     }
//   }
//
//   void _initializeUserStream() {
//     try {
//       _userStreamSubscription = chatController
//           .getUserInfoStream(user.id)
//           .listen((snapshot) {
//         if (!_isActiveController) {
//           _userStreamSubscription?.cancel();
//           return;
//         }
//
//         final data = snapshot.docs;
//         if (data.isNotEmpty) {
//           cachedUserData.value = ChatUser.fromJson(data.first.data());
//           _updateBlockStatus();
//           _precacheAvatars();
//         }
//       });
//     } catch (e) {
//       debugPrint('Error initializing user stream: $e');
//     }
//   }
//
//   void _initializeMessagesStream() {
//     try {
//       if (chatController.cachedMessagesPerUser.containsKey(user.id)) {
//         cachedMessages.value = chatController.cachedMessagesPerUser[user.id]!;
//         isInitialLoading.value = false;
//       }
//
//       _messagesSubscription = chatController
//           .getFilteredMessagesStream(user)
//           .listen((messages) {
//         if (!_isActiveController) {
//           _messagesSubscription?.cancel();
//           return;
//         }
//
//         cachedMessages.value = messages;
//         chatController.cachedMessagesPerUser[user.id] = messages;
//
//         if (isInitialLoading.value) {
//           debugPrint('✅ Message stream delivered. Turning off loading.');
//           isInitialLoading.value = false;
//         }
//
//         if (!paused.value &&
//             _isActiveController &&
//             chatController.selectedUser.value?.id == user.id) {
//           _markMessagesAsRead(messages);
//         }
//       });
//     } catch (e) {
//       debugPrint('Error initializing messages stream: $e');
//       isInitialLoading.value = false;
//     }
//   }
//
//   // ========== Helper Methods ==========
//   Future<void> _fetchCurrentUserProfile() async {
//     try {
//       final userDoc = await FirebaseFirestore.instance
//                     .collection(EnvConfig.firebaseUsersCollection)

//           .doc(currentUID)
//           .get();
//
//       if (userDoc.exists) {
//         final data = userDoc.data();
//         currentUserImageUrl.value = data?['image'] ?? AppConstants.profileImg;
//       }
//     } catch (e) {
//       debugPrint('Error fetching current user profile: $e');
//       currentUserImageUrl.value = AppConstants.profileImg;
//     }
//   }
//
//   void _precacheAvatars() {
//     try {
//       final ctx = Get.context;
//       if (ctx == null) return;
//
//       final otherUrl = user.image;
//       if (isValidNetworkUrl(otherUrl)) {
//         precacheImage(CachedNetworkImageProvider(otherUrl), ctx);
//       }
//
//       final meUrl = currentUserImageUrl.value;
//       if (isValidNetworkUrl(meUrl)) {
//         precacheImage(CachedNetworkImageProvider(meUrl), ctx);
//       }
//     } catch (_) {}
//   }
//
//   bool isValidNetworkUrl(String? url) {
//     if (url == null || url.isEmpty) return false;
//     final uri = Uri.tryParse(url);
//     return uri != null && (uri.isScheme('http') || uri.isScheme('https')) && (uri.host.isNotEmpty);
//   }
//
//   void _listenToKeyboardVisibility() {
//     final bottomInset = MediaQuery.of(Get.context!).viewInsets.bottom;
//     isKeyboardVisible.value = bottomInset > 0;
//   }
//
//   Future<void> _markMessagesAsDeliveredOnEntry() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     await chatController.markIncomingMessagesAsDelivered();
//     debugPrint('✅ Marked messages as delivered on chat entry');
//   }
//
//   void _markMessagesAsRead(List<Message> messages) {
//     if (!_isActiveController || messages.isEmpty) return;
//
//     if (chatController.selectedUser.value?.id != user.id) {
//       debugPrint('⚠️ Skipping mark as read - not the active chat');
//       return;
//     }
//
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (!_isActiveController || chatController.selectedUser.value?.id != user.id) {
//         return;
//       }
//
//       final unreadMessages = messages
//           .where((msg) => msg.fromId != currentUID && msg.read.isEmpty)
//           .toList();
//
//       debugPrint('📖 Marking ${unreadMessages.length} messages as read for user: ${user.id}');
//
//       for (var message in unreadMessages) {
//         if (_isActiveController && chatController.selectedUser.value?.id == user.id) {
//           chatController.markMessageAsRead(message);
//         }
//       }
//     });
//   }
//
//   void deactivate() {
//     _isActiveController = false;
//     paused.value = true;
//     _messagesSubscription?.cancel();
//     _userStreamSubscription?.cancel();
//   }
//
//   // ========== Typing Status Methods ==========
//   void _listenToTypingStatus() {
//     final conversationId = chatController.getConversationId(currentUID, user.id);
//
//     _typingStatusSubscription = FirebaseFirestore.instance
//                   .collection(EnvConfig.firebaseChatsCollection)

//         .doc(conversationId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists && snapshot.data() != null) {
//         final data = snapshot.data()!;
//         final typingStatus = data['typing_status'] as Map<String, dynamic>? ?? {};
//
//         if (typingStatus.containsKey(user.id)) {
//           final otherUserTyping = typingStatus[user.id] as Map<String, dynamic>;
//           final isTyping = otherUserTyping['is_typing'] as bool? ?? false;
//           final timestamp = otherUserTyping['timestamp'] as int? ?? 0;
//
//           final now = DateTime.now().millisecondsSinceEpoch;
//           final isRecent = (now - timestamp) < 3000;
//
//           isOtherUserTyping.value = isTyping && isRecent;
//         } else {
//           isOtherUserTyping.value = false;
//         }
//       }
//     });
//   }
//
//   void _onTextChanged() {
//     if (textController.text.isNotEmpty && !isAnyBlocked) {
//       _handleTyping();
//     } else {
//       _stopTyping();
//     }
//   }
//
//   void _handleTyping() {
//     _typingDebounceTimer?.cancel();
//     _updateTypingStatus(true);
//
//     _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
//       _stopTyping();
//     });
//   }
//
//   void _stopTyping() {
//     _typingDebounceTimer?.cancel();
//     _updateTypingStatus(false);
//   }
//
//   Future<void> _updateTypingStatus(bool isTyping) async {
//     try {
//       final conversationId = chatController.getConversationId(currentUID, user.id);
//
//       await FirebaseFirestore.instance
//                     .collection(EnvConfig.firebaseChatsCollection)

//           .doc(conversationId)
//           .set({
//         'typing_status': {
//           currentUID: {
//             'is_typing': isTyping,
//             'timestamp': DateTime.now().millisecondsSinceEpoch,
//           }
//         }
//       }, SetOptions(merge: true));
//     } catch (e) {
//       debugPrint('Error updating typing status: $e');
//     }
//   }
//
//   // ========== Status Update Methods ==========
//   void _listenForStatusUpdates() {
//     final conversationId = chatController.getConversationId(currentUID, user.id);
//
//     _statusUpdateSubscription?.cancel();
//
//     _statusUpdateSubscription = FirebaseFirestore.instance
//                   .collection(EnvConfig.firebaseChatsCollection)

//         .doc(conversationId)
//         .collection('messages')
//         .snapshots()
//         .listen((snapshot) {
//       bool hasChanges = false;
//       final updatedMessages = List<Message>.from(cachedMessages);
//
//       for (var change in snapshot.docChanges) {
//         if (change.doc.data() == null) continue;
//         final data = change.doc.data()!;
//         final messageId = change.doc.id;
//
//         if (change.type == DocumentChangeType.modified ||
//             change.type == DocumentChangeType.added) {
//           final index = updatedMessages.indexWhere((m) => m.sent == messageId);
//           if (index != -1) {
//             final message = updatedMessages[index];
//
//             final newStatus = _parseMessageStatus(data);
//             final newDelivered = data['delivered']?.toString() ?? '';
//             final newRead = data['read']?.toString() ?? '';
//
//             final hasChanged = message.status != newStatus ||
//                 message.read != newRead ||
//                 message.delivered != newDelivered;
//
//             if (hasChanged) {
//               final updatedMessage = Message(
//                 toId: message.toId,
//                 msg: message.msg,
//                 read: newRead,
//                 type: message.type,
//                 fromId: message.fromId,
//                 sent: message.sent,
//                 status: newStatus,
//                 delivered: newDelivered,
//                 isViewOnce: message.isViewOnce,
//                 isViewed: message.isViewed,
//                 reactions: message.reactions,
//               );
//
//               updatedMessages[index] = updatedMessage;
//               hasChanges = true;
//
//               debugPrint('📊 Status updated for message $messageId: ${newStatus.name}');
//             }
//           }
//         }
//       }
//
//       if (hasChanges) {
//         cachedMessages.assignAll(updatedMessages);
//         chatController.cachedMessagesPerUser[user.id] = updatedMessages;
//       }
//     });
//   }
//
//   MessageStatus _parseMessageStatus(Map<String, dynamic> data) {
//     if (data['read'] != null && data['read'].toString().isNotEmpty) {
//       return MessageStatus.read;
//     } else if (data['delivered'] != null && data['delivered'].toString().isNotEmpty) {
//       return MessageStatus.delivered;
//     } else if (data['status'] != null) {
//       try {
//         return MessageStatus.values.firstWhere(
//           (e) => e.name == data['status'],
//           orElse: () => MessageStatus.sent,
//         );
//       } catch (e) {
//         return MessageStatus.sent;
//       }
//     }
//     return MessageStatus.sent;
//   }
//
//   // ========== Message Sending Methods ==========
//   Future<void> sendMessage() async {
//     final message = textController.text.trim();
//     if (message.isEmpty) {
//       debugPrint('⚠️ Empty message, not sending');
//       return;
//     }
//
//     debugPrint('📤 Attempting to send message: $message');
//
//     if (chatController.selectedUser.value?.id != user.id) {
//       debugPrint('⚠️ Selected user mismatch, setting correct user');
//       chatController.selectedUser.value = user;
//     }
//
//     textController.clear();
//
//     try {
//       if (cachedMessages.isEmpty) {
//         debugPrint('📝 First message - creating chat');
//         await createUserChat(message);
//       } else {
//         debugPrint('💬 Sending regular message');
//         checkChatUser();
//         await sendRegularMessage(message);
//       }
//       debugPrint('✅ Message operation completed');
//     } catch (e) {
//       debugPrint('❌ Error in sendMessage: $e');
//       textController.text = message;
//       Get.snackbar(
//         'Error',
//         'Failed to send message. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> sendRegularMessage(String message) async {
//     if (chatController.selectedUser.value == null) {
//       debugPrint('⚠️ No selected user, setting it now');
//       chatController.selectedUser.value = user;
//     }
//
//     debugPrint('📨 Sending message with selected user: ${chatController.selectedUser.value?.name}');
//     await chatController.sendMessage(message);
//   }
//
//   Future<void> createUserChat(String firstMsg) async {
//     try {
//       debugPrint('🔄 Creating user chat with first message: $firstMsg');
//
//       chatController.selectedUser.value = user;
//
//       bool isAdded = await chatController.addChatUser(user.id);
//       debugPrint('📊 Chat user added result: $isAdded');
//
//       if (isAdded) {
//         await Future.delayed(const Duration(milliseconds: 300));
//
//         debugPrint('📨 Sending first message...');
//         await chatController.sendFirstMessage(firstMsg);
//         debugPrint('✅ First message sent successfully');
//       } else {
//         debugPrint('⚠️ User already exists, sending as regular message');
//         await sendRegularMessage(firstMsg);
//       }
//     } catch (e) {
//       debugPrint('❌ Error in createUserChat: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to start chat. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> sendHiMessage() async {
//     debugPrint('👋 Sending Hi message');
//     await createUserChat('Hi! 👋');
//   }
//
//   void checkChatUser() {
//     debugPrint('🔍 Checking/adding chat user');
//     unawaited(chatController.addChatUser(user.id).then((result) {
//       debugPrint('✅ Chat user check completed: $result');
//     }).catchError((e) {
//       debugPrint('⚠️ Chat user check error (non-critical): $e');
//     }));
//   }
//
//   // ========== Reply Feature Methods ==========
//   void handleReply(Message message) {
//     final isMe = useCase.getUserId().toString() == message.fromId;
//     final senderName = isMe ? 'You' : (cachedUserData.value?.name ?? 'User');
//
//     replyingTo.value = message;
//
//     String cleanMessage = message.msg;
//     if (cleanMessage.contains('↪️')) {
//       final parts = cleanMessage.split('\n\n');
//       if (parts.length > 1) {
//         cleanMessage = parts.sublist(1).join('\n\n');
//       }
//     }
//
//     final previewText = cleanMessage.length > 40
//         ? '${cleanMessage.substring(0, 40)}...'
//         : cleanMessage;
//
//     replyPreview.value = '$senderName: $previewText';
//
//     textController.text = '';
//     FocusScope.of(Get.context!).requestFocus(FocusNode());
//
//     HapticFeedback.lightImpact();
//   }
//
//   void clearReply() {
//     replyingTo.value = null;
//     replyPreview.value = '';
//   }
//
//   Future<void> sendMessageWithReply() async {
//     final message = textController.text.trim();
//     if (message.isEmpty) return;
//
//     final finalMessage = replyingTo.value != null
//         ? '↪️ ${replyPreview.value}\n\n$message'
//         : message;
//
//     textController.clear();
//     clearReply();
//
//     try {
//       if (cachedMessages.isEmpty) {
//         await createUserChat(finalMessage);
//       } else {
//         checkChatUser();
//         await sendRegularMessage(finalMessage);
//       }
//     } catch (e) {
//       debugPrint('Error sending message: $e');
//       textController.text = message;
//       Get.snackbar(
//         'Error',
//         'Failed to send message. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // ========== Message Selection Methods ==========
//   String getSelectionCountText() {
//     final count = selectedMessages.length;
//     if (count == 0) return 'No messages selected';
//     if (count == 1) return '1 message selected';
//     return '$count messages selected';
//   }
//
//   void enterSelectionMode(Message initialMessage) {
//     isSelectionMode.value = true;
//     selectedMessages.clear();
//     selectedMessages.add(initialMessage);
//     HapticFeedback.lightImpact();
//
//     _scrollToSelectedMessage(initialMessage);
//     FocusManager.instance.primaryFocus?.unfocus();
//
//     Future.delayed(const Duration(milliseconds: 400), () {
//       _scrollToSelectedMessage(initialMessage);
//     });
//   }
//
//   void exitSelectionMode() {
//     isSelectionMode.value = false;
//     selectedMessages.clear();
//     HapticFeedback.lightImpact();
//   }
//
//   void toggleMessageSelection(Message message) {
//     if (selectedMessages.contains(message)) {
//       selectedMessages.remove(message);
//       if (selectedMessages.isEmpty) {
//         exitSelectionMode();
//       }
//     } else {
//       selectedMessages.add(message);
//       _scrollToSelectedMessage(message);
//     }
//     HapticFeedback.selectionClick();
//   }
//
//   void _scrollToSelectedMessage(Message message) {
//     if (!scrollController.hasClients || cachedMessages.isEmpty) return;
//
//     final messageIndex = cachedMessages.indexOf(message);
//     if (messageIndex == -1) return;
//
//     const double estimatedItemHeight = 100.0;
//     final double listHeight = scrollController.position.viewportDimension;
//
//     final double targetPosition = messageIndex * estimatedItemHeight;
//
//     final double currentPosition = scrollController.offset;
//     final double messageTop = targetPosition;
//     final double messageBottom = messageTop + estimatedItemHeight;
//
//     if (messageTop < currentPosition || messageBottom > currentPosition + listHeight) {
//       scrollController.animateTo(
//         targetPosition,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   bool isMessageSelected(Message message) {
//     return selectedMessages.contains(message);
//   }
//
//   void selectAllMessages() {
//     selectedMessages.clear();
//     selectedMessages.addAll(cachedMessages);
//     HapticFeedback.lightImpact();
//   }
//
//   void deselectAllMessages() {
//     selectedMessages.clear();
//     exitSelectionMode();
//     HapticFeedback.lightImpact();
//   }
//
//   // ========== Bulk Actions Methods ==========
//   Future<void> deleteSelectedMessages() async {
//     if (selectedMessages.isEmpty) return;
//
//     final int messageCount = selectedMessages.length;
//     final List<Message> messagesToDelete = List.from(selectedMessages);
//
//     final confirmed = await Get.dialog<bool>(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Delete $messageCount message${messageCount > 1 ? 's' : ''}?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Get.back(result: true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     ) ?? false;
//
//     if (confirmed) {
//       showLoading.value = true;
//       int successCount = 0;
//       int failCount = 0;
//
//       try {
//         for (final message in messagesToDelete) {
//           try {
//             await chatController.deleteMessage(message);
//             successCount++;
//           } catch (e) {
//             failCount++;
//             debugPrint('Failed to delete message: ${message.sent}');
//           }
//         }
//
//         exitSelectionMode();
//
//         if (failCount == 0) {
//           AppUtils.successData(
//             title: "Deleted",
//             message: '$successCount message${successCount > 1 ? 's' : ''} deleted successfully',
//           );
//         } else {
//           AppUtils.failedData(
//             title: "Partial Success",
//             message: '$successCount deleted, $failCount failed',
//           );
//         }
//       } catch (e) {
//         AppUtils.failedData(
//           title: "Error",
//           message: 'Failed to delete messages',
//         );
//       } finally {
//         showLoading.value = false;
//       }
//     }
//   }
//
//   Future<void> copySelectedMessages() async {
//     if (selectedMessages.isEmpty) return;
//
//     final int messageCount = selectedMessages.length;
//
//     try {
//       final sortedMessages = List<Message>.from(selectedMessages)
//         ..sort((a, b) => a.sent.compareTo(b.sent));
//
//       final buffer = StringBuffer();
//       int copiedCount = 0;
//
//       for (final message in sortedMessages) {
//         if (message.type == Type.text) {
//           final senderName = message.fromId == currentUID ? 'You' : user.name;
//           final time = MyDateUtill.getFormatedTime(
//             context: Get.context!,
//             time: message.sent,
//           );
//
//           String messageText = message.msg;
//           if (messageText.contains('↪️')) {
//             final parts = messageText.split('\n\n');
//             if (parts.length > 1) {
//               messageText = parts.sublist(1).join('\n\n');
//             }
//           }
//
//           buffer.writeln('[$time] $senderName: $messageText');
//           copiedCount++;
//         }
//       }
//
//       if (buffer.isNotEmpty) {
//         await Clipboard.setData(ClipboardData(text: buffer.toString()));
//         exitSelectionMode();
//
//         AppUtils.successData(
//           title: "Copied",
//           message: '$copiedCount message${copiedCount > 1 ? 's' : ''} copied to clipboard',
//         );
//       } else {
//         AppUtils.failedData(
//           title: "Info",
//           message: 'No text messages to copy',
//         );
//         exitSelectionMode();
//       }
//     } catch (e) {
//       AppUtils.failedData(
//         title: "Error",
//         message: 'Failed to copy messages',
//       );
//     }
//   }
//
//   Future<void> forwardSelectedMessages() async {
//     if (selectedMessages.isEmpty) return;
//
//     final int messageCount = selectedMessages.length;
//     final List<Message> messagesToForward = List.from(selectedMessages);
//
//     exitSelectionMode();
//
//     AppUtils.successData(
//       title: "Forward",
//       message: '$messageCount message${messageCount > 1 ? 's' : ''} selected for forwarding',
//     );
//   }
//
//   void _retryFailedMessage(Message failedMessage) async {
//     try {
//       cachedMessages.removeWhere((m) => m.sent == failedMessage.sent);
//       await sendRegularMessage(failedMessage.msg);
//       debugPrint('✅ Message retry successful');
//     } catch (e) {
//       debugPrint('❌ Message retry failed: $e');
//       Get.snackbar(
//         'Retry Failed',
//         'Unable to resend message',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // ========== Image Handling Methods ==========
//   Future<void> showImageOptions() async {
//     showModalBottomSheet(
//       context: Get.context!,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 20),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 10),
//             ListTile(
//               leading: Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.timelapse, color: Colors.orange),
//               ),
//               title: const Text(
//                 'Send View Once Image',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               subtitle: const Text('Image will disappear after viewing'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showImageSourceOptions(isViewOnce: true);
//               },
//             ),
//             SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _showImageSourceOptions({required bool isViewOnce}) async {
//     showModalBottomSheet(
//       context: Get.context!,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: <Widget>[
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Gallery'),
//               onTap: () {
//                 _pickImage(source: ImageSource.gallery, isViewOnce: isViewOnce);
//                 Navigator.of(context).pop();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_camera),
//               title: const Text('Camera'),
//               onTap: () {
//                 _pickImage(source: ImageSource.camera, isViewOnce: isViewOnce);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickImage({required ImageSource source, required bool isViewOnce}) async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: source,
//       imageQuality: 70,
//     );
//
//     if (image == null) return;
//
//     if (isViewOnce && source == ImageSource.gallery) {
//       final confirmed = await _showViewOnceConfirmationDialog(File(image.path));
//       if (!confirmed) return;
//     }
//
//     uploading.value = true;
//     try {
//       if (isViewOnce) {
//         await chatController.sendViewOnceImage(
//           useCase.getUserId().toString(),
//           File(image.path),
//         );
//       } else {
//         await chatController.sendImage(
//           useCase.getUserId().toString(),
//           File(image.path),
//         );
//       }
//     } finally {
//       uploading.value = false;
//     }
//   }
//
//   Future<bool> _showViewOnceConfirmationDialog(File imageFile) async {
//     return await Get.dialog<bool>(
//       AlertDialog.adaptive(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(
//           children: [
//             Icon(Icons.timelapse_rounded, color: Colors.orange),
//             SizedBox(width: 10),
//             Text('Send as View-Once?'),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(imageFile, height: 150, fit: BoxFit.cover),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'This photo will disappear after it has been viewed once by the recipient.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14, color: Colors.black54),
//               ),
//             ],
//           ),
//         ),
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton.icon(
//             onPressed: () => Get.back(result: true),
//             icon: const Icon(Icons.send_rounded, size: 18),
//             label: const Text('Send'),
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: AppColors.secondaryColor,
//             ),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }
//
//   // ========== UI State Methods ==========
//   void toggleEmoji() {
//     FocusManager.instance.primaryFocus?.unfocus();
//     showEmoji.value = !showEmoji.value;
//   }
//
//   void hideEmoji() {
//     if (showEmoji.value) {
//       showEmoji.value = false;
//
//       if (isSelectionMode.value && selectedMessages.isNotEmpty) {
//         Future.delayed(const Duration(milliseconds: 300), () {
//           _scrollToSelectedMessage(selectedMessages.first);
//         });
//       }
//     }
//   }
//
//   void onTextFieldTap() {
//     if (showEmoji.value) {
//       showEmoji.value = false;
//     }
//
//     if (isSelectionMode.value) {
//       exitSelectionMode();
//     }
//   }
//
//   // ========== Navigation Methods ==========
//   Future<void> navigateBack() async {
//     debugPrint('⬅️ Navigating back from chat');
//
//     _isActiveController = false;
//     paused.value = true;
//
//     _messagesSubscription?.cancel();
//     _userStreamSubscription?.cancel();
//
//     if (Get.isRegistered<ChatListController>()) {
//       final listController = Get.find<ChatListController>();
//       if (!listController.isLoading.value ||
//           !listController.isRefreshing.value ||
//           !listController.isNavigatingToChat.value) {
//         await listController.ensureStreamsActive();
//       }
//     }
//
//     if (Navigator.of(Get.context!).canPop()) {
//       Get.back();
//     } else {
//       Get.offNamed(AppRoutes.BOTTOM_NAV2, arguments: 2);
//     }
//   }
//
//   // ========== Getters ==========
//   bool get isDisposed => _isDisposed;
//   TextEditingController? get safeTextController => _isDisposed ? null : textController;
//   ChatUser get currentUserData => cachedUserData.value ?? user;
//   bool get isAnyBlocked => isBlocked.value || isBlockedByOther.value || isDelete.value;
//
//   String get userImageUrl => currentUserData.image.isNotEmpty
//       ? currentUserData.image
//       : AppConstants.profileImg;
//
//   String get blockMessage => isBlockedByOther.value || isDelete.value
//       ? "You can no longer message this user"
//       : "You have blocked this user";
//
//   String get emptyStateMessage {
//     if (isAnyBlocked) {
//       return isBlockedByOther.value
//           ? 'You can no longer message this user'
//           : 'You have blocked this user';
//     }
//
//     if (chatController.currentChatDeletionTime.value != null) {
//       return 'Chat history cleared';
//     }
//
//     return 'No messages yet';
//   }
//
//   String get emptyStateSubtitle {
//     if (isAnyBlocked) return '';
//
//     return chatController.currentChatDeletionTime.value != null
//         ? 'Send a message to start fresh'
//         : 'Start the conversation';
//   }
//
//   IconData get emptyStateIcon {
//     if (isAnyBlocked) return Icons.block_rounded;
//     if (chatController.currentChatDeletionTime.value != null) return Icons.restart_alt;
//     return Icons.chat_bubble_outline;
//   }
//
//   Color? get emptyStateIconColor {
//     return isAnyBlocked ? Colors.red[300] : Colors.grey[400];
//   }
//
//   Color? get emptyStateTextColor {
//     return isAnyBlocked ? Colors.red[700] : Colors.grey[600];
//   }
// }
