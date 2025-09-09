// Optimized ChattingView with instant block status display
// chatting_view.dart

import 'dart:async';
import 'dart:io';

import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/export.dart';
import '../../domain/export.dart';
import '../../utils/exports.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/chat_list_viewmodel.dart';
import '../../widgets/export.dart';
import '../../widgets/typing_indicator.dart';

// State Management Controller for ChattingView
// Fixed ChattingViewController in chatting_view.dart
// This fixes the issue where messages from Account A were being marked as read
// when navigating to Account B's chat via notification

class ChattingViewController extends GetxController with WidgetsBindingObserver {
  final ChatUser user;
  final currentUserProfile = Rx<String?>(null);
  final bool? initialBlockedStatus;
  final bool? initialBlockedByOtherStatus;
  final bool? initialDeletedStatus;
  final replyingTo = Rxn<Message>();
  final replyPreview = ''.obs;
  ChattingViewController({
    required this.user,
    this.initialBlockedStatus,
    this.initialBlockedByOtherStatus,
    this.initialDeletedStatus
  });

  // Dependencies
  final useCase = Get.find<UserManagementUseCase>();
  final chatController = Get.find<ChatViewModel>();
  final chatListController = Get.find<ChatListController>();
  var profileDetails = CurrentUserProfile().obs;
  // Text controller
  late TextEditingController textController;

  // Observable states
  final showEmoji = false.obs;
  final uploading = false.obs;
  final paused = false.obs;
  late final RxBool isBlocked;
  late final RxBool isBlockedByOther;
  late final RxBool isDelete;
  final isInitialLoading = true.obs;
  final showLoading = false.obs;
  // Add disposal flag
  bool _isDisposed = false;
  // Messages and user data
  final cachedMessages = <Message>[].obs;
  final cachedUserData = Rx<ChatUser?>(null);

  // Stream subscriptions
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription? _userStreamSubscription;
  StreamSubscription? _statusUpdateSubscription;
  String currentUID = "";

  // FIXED: Add flag to track if this controller is active
  bool _isActiveController = false;

  // FIXED: Track the current chat user ID properly
  String? _currentChatUserId;
  // Typing status
  final RxBool isOtherUserTyping = false.obs;
  StreamSubscription? _typingStatusSubscription;
  Timer? _typingDebounceTimer;
  // Current user ki profile image URL store karne ke liye
  final currentUserImageUrl = ''.obs;
  @override
  void onInit() {
    super.onInit();
    // Add disposal flag
   _isDisposed = false;
    WidgetsBinding.instance.addObserver(this);
    currentUID = useCase.getUserId().toString();
    textController = TextEditingController();
    // Set up text field listener for typing
    textController.addListener(_onTextChanged);
    _fetchCurrentUserProfile();
    // Start listening to typing status
    _listenToTypingStatus();
    // FIXED: Set current chat user ID
    _currentChatUserId = user.id;

    // Initialize block status with passed values or false
    isBlocked = (initialBlockedStatus ?? false).obs;
    isBlockedByOther = (initialBlockedByOtherStatus ?? false).obs;
    isDelete = (initialDeletedStatus ?? false).obs;

    // FIXED: Mark this controller as active
    _isActiveController = true;
    _markMessagesAsDeliveredOnEntry();
    _initializeChat();
  }
  // Add this method to fetch current user's profile
  Future<void> _fetchCurrentUserProfile() async {
    try {
      // Get current user's profile from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(currentUID)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        currentUserImageUrl.value = data?['image'] ?? AppConstants.profileImg;
      }
    } catch (e) {
      debugPrint('Error fetching current user profile: $e');
      currentUserImageUrl.value = AppConstants.profileImg;
    }
  }

  void _listenToTypingStatus() {
    final conversationId = chatController.getConversationId(
      currentUID,
      user.id,
    );

    _typingStatusSubscription = FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final typingStatus = data['typing_status'] as Map<String, dynamic>? ?? {};

        if (typingStatus.containsKey(user.id)) {
          final otherUserTyping = typingStatus[user.id] as Map<String, dynamic>;
          final isTyping = otherUserTyping['is_typing'] as bool? ?? false;
          final timestamp = otherUserTyping['timestamp'] as int? ?? 0;

          // Check if typing status is recent (within last 3 seconds)
          final now = DateTime.now().millisecondsSinceEpoch;
          final isRecent = (now - timestamp) < 3000;

          isOtherUserTyping.value = isTyping && isRecent;
        } else {
          isOtherUserTyping.value = false;
        }
      }
    });
  }
  Future<void> _markMessagesAsDeliveredOnEntry() async {
    // Small delay to ensure proper initialization
    await Future.delayed(const Duration(milliseconds: 500));

    // Mark all undelivered messages as delivered
    await chatController.markIncomingMessagesAsDelivered();

    debugPrint('✅ Marked messages as delivered on chat entry');
  }
  // Handle text changes for typing indicator
  void _onTextChanged() {
    if (textController.text.isNotEmpty && !isAnyBlocked) {
      _handleTyping();
    } else {
      _stopTyping();
    }
  }

  // Handle typing with debounce
  void _handleTyping() {
    _typingDebounceTimer?.cancel();

    // Send typing status
    _updateTypingStatus(true);

    // Stop typing after 2 seconds of inactivity
    _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
      _stopTyping();
    });
  }

  // Stop typing
  void _stopTyping() {
    _typingDebounceTimer?.cancel();
    _updateTypingStatus(false);
  }

  // Update typing status in Firestore
  Future<void> _updateTypingStatus(bool isTyping) async {
    try {
      final conversationId = chatController.getConversationId(
        currentUID,
        user.id,
      );

      await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(conversationId)
          .set({
        'typing_status': {
          currentUID: {
            'is_typing': isTyping,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating typing status: $e');
    }
  }
  void _retryFailedMessage(Message failedMessage) async {
    try {
      // Remove failed message from list
      cachedMessages.removeWhere((m) => m.sent == failedMessage.sent);

      // Resend the message
      await sendRegularMessage(failedMessage.msg);

      debugPrint('✅ Message retry successful');
    } catch (e) {
      debugPrint('❌ Message retry failed: $e');
      Get.snackbar(
        'Retry Failed',
        'Unable to resend message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  void _listenForStatusUpdates() {
    final conversationId = chatController.getConversationId(
      currentUID,
      user.id,
    );

    // Cancel previous subscription if exists
    _statusUpdateSubscription?.cancel();

    _statusUpdateSubscription = FirebaseFirestore.instance
        .collection('Hamid_chats')
        .doc(conversationId)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {

      for (var change in snapshot.docChanges) {
        final data = change.doc.data()!;
        final messageId = change.doc.id;

        // Handle both added and modified messages
        if (change.type == DocumentChangeType.modified ||
            change.type == DocumentChangeType.added) {

          // Find message in local list
          final index = cachedMessages.indexWhere((m) => m.sent == messageId);
          if (index != -1) {
            final message = cachedMessages[index];

            // Update status based on data
            final newStatus = _parseMessageStatus(data);
            final hasChanged = message.status != newStatus ||
                message.read != (data['read'] ?? '') ||
                message.delivered != (data['delivered'] ?? '');

            if (hasChanged) {
              // Update message fields
              message.status = newStatus;
              message.delivered = data['delivered'] ?? '';
              message.read = data['read'] ?? '';

              // Force refresh
              cachedMessages[index] = message;
              cachedMessages.refresh();

              debugPrint('📊 Status updated for message ${messageId}: ${newStatus.name}');
            }
          }
        }
      }
    });
  }
  MessageStatus _parseMessageStatus(Map<String, dynamic> data) {
    // Check read first
    if (data['read'] != null && data['read'].toString().isNotEmpty) {
      return MessageStatus.read;
    }
    // Then check delivered
    else if (data['delivered'] != null && data['delivered'].toString().isNotEmpty) {
      return MessageStatus.delivered;
    }
    // Check explicit status field
    else if (data['status'] != null) {
      try {
        return MessageStatus.values.firstWhere(
              (e) => e.name == data['status'],
          orElse: () => MessageStatus.sent,
        );
      } catch (e) {
        return MessageStatus.sent;
      }
    }
    // Default to sent
    return MessageStatus.sent;
  }
// Add image picking methods
  // Enhanced reply method
  void _handleReply(Message message) {
    final isMe = useCase.getUserId().toString() == message.fromId;
    final senderName = isMe ? 'You' : (cachedUserData.value?.name ?? 'User');

    // Set reply context
    replyingTo.value = message;

    // Create preview text
    final previewText = message.msg.length > 40
        ? message.msg.substring(0, 40) + '...'
        : message.msg;

    replyPreview.value = '$senderName: $previewText';

    // Focus text field
    textController.text = '';
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    HapticFeedback.lightImpact();
  }
  void _clearReply() {
    replyingTo.value = null;
    replyPreview.value = '';
  }
  // Enhanced send message with reply support
  Future<void> _sendMessageWithReply() async {
    final message = textController.text.trim();
    if (message.isEmpty) return;

    final finalMessage = replyingTo.value != null
        ? '↪️ ${replyPreview.value}\n\n$message'
        : message;

    textController.clear();
    _clearReply(); // Clear reply context

    try {
      if (cachedMessages.isEmpty) {
        await createUserChat(finalMessage);
      } else {
        checkChatUser();
        await sendRegularMessage(finalMessage);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      textController.text = message; // Restore on error
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

Future<void> showImageOptions() async {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ListTile(
            //   leading: Container(
            //     padding: const EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: Colors.blue.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: const Icon(Icons.photo_library, color: Colors.blue),
            //   ),
            //   title: const Text(
            //     'Send Normal Image',
            //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            //   ),
            //   subtitle: const Text('Image will remain in chat'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _pickImage(isViewOnce: false);
            //   },
            // ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timelapse, color: Colors.orange),
              ),
              title: const Text(
                'Send View Once Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Image will disappear after viewing'),
              onTap: () {
                Navigator.pop(context);
                _showImageSourceOptions(isViewOnce: true);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceOptions({required bool isViewOnce}) async {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(source: ImageSource.gallery, isViewOnce: isViewOnce);
                  Navigator.of(context).pop();
                }),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(source: ImageSource.camera, isViewOnce: isViewOnce);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
      {required ImageSource source, required bool isViewOnce}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source, // Use the provided source parameter
      imageQuality: 70,
    );

    if (image == null) return;

    // Show confirmation for view-once images from the gallery
    if (isViewOnce && source == ImageSource.gallery) {
      final confirmed = await _showViewOnceConfirmationDialog(File(image.path));
      if (!confirmed) {
        return; // User cancelled
      }
    }

    if (image != null) {
      uploading.value = true;
      try {
        if (isViewOnce) {
          // Send as view-once image
          await chatController.sendViewOnceImage(
            useCase.getUserId().toString(),
            File(image.path),
          );
        } else {
          // Send as normal image
          await chatController.sendImage(
            useCase.getUserId().toString(),
            File(image.path),
          );
        }
      } finally {
        uploading.value = false;
      }
    }
  }

  Future<bool> _showViewOnceConfirmationDialog(File imageFile) async {
    return await Get.dialog<bool>(
      AlertDialog.adaptive(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.timelapse_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Send as View-Once?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile, height: 150, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              const Text(
                'This photo will disappear after it has been viewed once by the recipient.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Send'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.secondaryColor,
            ),
          ),
        ],
      ),
    ) ?? false; // Return false if dialog is dismissed
  }



  @override
  void onClose() {
    debugPrint('🗑️ Closing ChattingViewController for ${user.name}');

    // Mark controller as inactive
    _isActiveController = false;
    _currentChatUserId = null;
    _statusUpdateSubscription?.cancel();
    // Cancel all subscriptions
    _messagesSubscription?.cancel();
    _userStreamSubscription?.cancel();
    _messagesSubscription = null;
    _userStreamSubscription = null;
    _stopTyping();
    _typingDebounceTimer?.cancel();
    _typingStatusSubscription?.cancel();
    textController.removeListener(_onTextChanged);
    // CRITICAL: Properly exit chat and clear state
    if (chatController.selectedUser.value?.id == user.id) {
      chatController.exitChat();
    }

    // CRITICAL: Force clear chat state to ensure no lingering references
    chatController.forceClearChatState();

    // Clear chat status
    chatController.setInsideChatStatus(false);

    // Ensure chat list controller is active
    if (Get.isRegistered<ChatListController>()) {
      final listController = Get.find<ChatListController>();
      // Small delay to ensure proper cleanup
      Future.delayed(const Duration(milliseconds: 200), () {
        listController.ensureStreamsActive();
      });
    }

    WidgetsBinding.instance.removeObserver(this);

    // Dispose text controller if not already disposed
    if (!_isDisposed) {
      textController.dispose();
      _isDisposed = true;
    }

    super.onClose();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // FIXED: Only handle lifecycle if this controller is active
    if (!_isActiveController) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_currentChatUserId == user.id && _isActiveController) {
          chatController.setInsideChatStatus(true, chatUserId: user.id);
          paused.value = false;

          // Mark messages as delivered and read when app resumes
          if (chatController.selectedUser.value?.id == user.id) {
            chatController.markIncomingMessagesAsDelivered();
            _markMessagesAsRead(cachedMessages);
          }
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (_isActiveController) {
          chatController.setInsideChatStatus(false);
          paused.value = true;
        }
        break;
    }
  }

  // Initialize chat with proper loading states
  Future<void> _initializeChat() async {
    // FIXED: Set this user as the selected user immediately
    chatController.selectedUser.value = user;
    debugPrint('✅ Selected user set to: ${user.name} (${user.id})');


    // Immediately show cached messages if available
    if (chatController.cachedMessagesPerUser.containsKey(user.id)) {
      cachedMessages.value = chatController.cachedMessagesPerUser[user.id]!;
    }

    // Set chat status first
    chatController.setInsideChatStatus(true, chatUserId: user.id);
    chatController.checkDeletionRecord();
// Mark incoming messages as delivered when entering chat
    await chatController.markIncomingMessagesAsDelivered();
// Start listening for status updates
    _listenForStatusUpdates();
    // Start all operations in parallel
    _updateBlockStatus(); // Update in background without waiting
    _initializeMessagesStream();
    _initializeUserStream();
  }

  // Update block status in background
  Future<void> _updateBlockStatus() async {
    try {
      final results = await Future.wait([
        chatController.isUserBlocked(user.id),
        chatController.isBlockedByFriend(user.id),
      ]);

      isBlocked.value = results[0];
      isBlockedByOther.value = results[1];
    } catch (e) {
      debugPrint('Error checking block status: $e');
    }
  }

  // Initialize user data stream
  void _initializeUserStream() {
    try {
      _userStreamSubscription = chatController
          .getUserInfoStream(user.id)
          .listen((snapshot) {
        // FIXED: Check if controller is still active
        if (!_isActiveController) {
          _userStreamSubscription?.cancel();
          return;
        }

        final data = snapshot.docs;
        if (data.isNotEmpty) {
          cachedUserData.value = ChatUser.fromJson(data.first.data());
          // Update block status when user data changes
          _updateBlockStatus();
        }
      });
    } catch (e) {
      debugPrint('Error initializing user stream: $e');
    }
  }

  void _initializeMessagesStream() {
    try {
      if (chatController.cachedMessagesPerUser.containsKey(user.id)) {
        cachedMessages.value = chatController.cachedMessagesPerUser[user.id]!;
        isInitialLoading.value = false;
      }

      _messagesSubscription = chatController
          .getFilteredMessagesStream(user)
          .listen((messages) {
        // FIXED: Check if this controller is still active
        if (!_isActiveController) {
          _messagesSubscription?.cancel();
          return;
        }

        cachedMessages.value = messages;

        // Save in controller-level cache
        chatController.cachedMessagesPerUser[user.id] = messages;

        if (isInitialLoading.value) {
          debugPrint('✅ Message stream delivered. Turning off loading.');
          isInitialLoading.value = false;
        }

        // FIXED: Only mark messages as read if:
        // 1. App is not paused
        // 2. This controller is active
        // 3. This is the currently selected user in chatController
        if (!paused.value &&
            _isActiveController &&
            chatController.selectedUser.value?.id == user.id) {
          _markMessagesAsRead(messages);
        }
      });
    } catch (e) {
      debugPrint('Error initializing messages stream: $e');
      isInitialLoading.value = false;
    }
  }

  void _markMessagesAsRead(List<Message> messages) {
    // FIXED: Additional safety check
    if (!_isActiveController || messages.isEmpty) return;

    // FIXED: Verify this is still the active chat
    if (chatController.selectedUser.value?.id != user.id) {
      debugPrint('⚠️ Skipping mark as read - not the active chat');
      return;
    }

    // Use a single batch operation for better performance
    Future.delayed(const Duration(milliseconds: 300), () {
      // FIXED: Final check before marking as read
      if (!_isActiveController || chatController.selectedUser.value?.id != user.id) {
        return;
      }

      final unreadMessages = messages
          .where((msg) => msg.fromId != currentUID && msg.read.isEmpty)
          .toList();

      debugPrint('📖 Marking ${unreadMessages.length} messages as read for user: ${user.id}');

      for (var message in unreadMessages) {
        // FIXED: Only mark if still the active chat
        if (_isActiveController && chatController.selectedUser.value?.id == user.id) {
          chatController.markMessageAsRead(message);
        }
      }
    });
  }

  // FIXED: Method to deactivate this controller when navigating away
  void deactivate() {
    _isActiveController = false;
    paused.value = true;
    _messagesSubscription?.cancel();
    _userStreamSubscription?.cancel();
  }

  // Message sending methods
  // Message sending methods with better error handling
  Future<void> sendMessage() async {
    final message = textController.text.trim();
    if (message.isEmpty) {
      debugPrint('⚠️ Empty message, not sending');
      return;
    }

    debugPrint('📤 Attempting to send message: $message');
    // CRITICAL FIX: Ensure selected user is set before sending
    if (chatController.selectedUser.value?.id != user.id) {
      debugPrint('⚠️ Selected user mismatch, setting correct user');
      chatController.selectedUser.value = user;
    }
    textController.clear();

    try {
      // Check if this is first message
      if (cachedMessages.isEmpty) {
        debugPrint('📝 First message - creating chat');
        await createUserChat(message);
      } else {
        debugPrint('💬 Sending regular message');
        // Ensure user is added (non-blocking)
        checkChatUser();
        // Send the message
        // FIXED: Send with proper user context
        await sendRegularMessage(message);
      }
      debugPrint('✅ Message operation completed');
    } catch (e) {
      debugPrint('❌ Error in sendMessage: $e');
      // Restore text if send failed
      textController.text = message;
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
// NEW: Separate method for sending regular messages with user check
  Future<void> sendRegularMessage(String message) async {
    // Double-check selected user is set
    if (chatController.selectedUser.value == null) {
      debugPrint('⚠️ No selected user, setting it now');
      chatController.selectedUser.value = user;
    }

    debugPrint('📨 Sending message with selected user: ${chatController.selectedUser.value?.name}');
    await chatController.sendMessage(message);
  }

  Future<void> createUserChat(String firstMsg) async {
    try {
      debugPrint('🔄 Creating user chat with first message: $firstMsg');

      // FIXED: Ensure selected user is set before creating chat
      chatController.selectedUser.value = user;

      bool isAdded = await chatController.addChatUser(user.id);
      debugPrint('📊 Chat user added result: $isAdded');

      if (isAdded) {
        // Small delay to ensure user is properly added
        await Future.delayed(const Duration(milliseconds: 300));

        // Send first message
        debugPrint('📨 Sending first message...');
        await chatController.sendFirstMessage(firstMsg);
        debugPrint('✅ First message sent successfully');
      } else {
        debugPrint('⚠️ User already exists, sending as regular message');
        // Try sending as regular message
        await sendRegularMessage(firstMsg);
      }
    } catch (e) {
      debugPrint('❌ Error in createUserChat: $e');
      Get.snackbar(
        'Error',
        'Failed to start chat. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  Future<void> sendHiMessage() async {
    debugPrint('👋 Sending Hi message');
    await createUserChat('Hi! 👋');
  }


  void checkChatUser() {
    debugPrint('🔍 Checking/adding chat user');
    // Use unawaited to not block
    unawaited(chatController.addChatUser(user.id).then((result) {
      debugPrint('✅ Chat user check completed: $result');
    }).catchError((e) {
      debugPrint('⚠️ Chat user check error (non-critical): $e');
    }));
  }
  // UI state methods
  void toggleEmoji() {
    FocusManager.instance.primaryFocus?.unfocus();
    showEmoji.value = !showEmoji.value;
  }

  void hideEmoji() {
    if (showEmoji.value) {
      showEmoji.value = false;
    }
  }

  void onTextFieldTap() {
    if (showEmoji.value) {
      showEmoji.value = false;
    }
  }

  // Navigation methods
  // void navigateBack() {
  //   // FIXED: Deactivate controller before navigating
  //   deactivate();
  //
  //   if (Navigator.of(Get.context!).canPop()) {
  //     Get.back();
  //   } else {
  //     Get.offAll(() => const BottomNavView(index: 2));
  //   }
  // }
// FIXED: Navigation methods with better cleanup
  Future<void> navigateBack() async {
    debugPrint('⬅️ Navigating back from chat');

    // Deactivate this controller first
    _isActiveController = false;
    paused.value = true;
    // Cancel streams
    _messagesSubscription?.cancel();
    _userStreamSubscription?.cancel();

    // CRITICAL: Clear chat state before navigating back
    // await chatController.forceClearChatState();
    // Ensure chat list is ready
    if (!Get.isRegistered<ChatListController>() || Get.isRegistered<ChatListController>()) {
      final listController = Get.find<ChatListController>();
      if (!listController.isLoading.value ||
                    !listController.isRefreshing.value ||
                    !listController.isNavigatingToChat.value) {
        await listController.ensureStreamsActive();
      }
    }

    // Small delay for smooth transition
    // Future.delayed(const Duration(milliseconds: 100), () {
      if (Navigator.of(Get.context!).canPop()) {
        // Get.offNamed(AppRoutes.BOTTOM_NAV2, arguments: 2);
        Get.back();
      } else {
         Get.offNamed(AppRoutes.BOTTOM_NAV2, arguments: 2);
        //Get.to(() => const BottomNavView(index: 2));
      }
    // });
  }
  // Check disposal before operations
  bool get isDisposed => _isDisposed;
  TextEditingController? get safeTextController => _isDisposed ? null : textController;

  // Getters remain the same...
  ChatUser get currentUserData => cachedUserData.value ?? user;
  bool get isAnyBlocked => isBlocked.value || isBlockedByOther.value || isDelete.value;
  String get userImageUrl => currentUserData.image.isNotEmpty
      ? currentUserData.image
      : AppConstants.profileImg;
  String get blockMessage => isBlockedByOther.value || isDelete.value
      ? "You can no longer message this user"
      : "You have blocked this user";

  String get emptyStateMessage {
    if (isAnyBlocked) {
      return isBlockedByOther.value
          ? 'You can no longer message this user'
          : 'You have blocked this user';
    }

    if (chatController.currentChatDeletionTime.value != null) {
      return 'Chat history cleared';
    }

    return 'No messages yet';
  }

  String get emptyStateSubtitle {
    if (isAnyBlocked) return '';

    return chatController.currentChatDeletionTime.value != null
        ? 'Send a message to start fresh'
        : 'Start the conversation';
  }

  IconData get emptyStateIcon {
    if (isAnyBlocked) return Icons.block_rounded;
    if (chatController.currentChatDeletionTime.value != null) return Icons.restart_alt;
    return Icons.chat_bubble_outline;
  }

  Color? get emptyStateIconColor {
    return isAnyBlocked ? Colors.red[300] : Colors.grey[400];
  }

  Color? get emptyStateTextColor {
    return isAnyBlocked ? Colors.red[700] : Colors.grey[600];
  }
}
// Modified ChattingView to accept initial block status
// 1. FIXED ChattingView - Proper controller management
class ChattingView extends StatefulWidget {  // Changed to StatefulWidget
  final ChatUser user;
  final bool? isBlocked;
  final bool? isBlockedByOther;
  final bool? isDeleted;

  const ChattingView({
    super.key,
    required this.user,
    this.isBlocked,
    this.isBlockedByOther,
    this.isDeleted
  });

  @override
  State<ChattingView> createState() => _ChattingViewState();
}

class _ChattingViewState extends State<ChattingView> {
  late ChattingViewController controller;
  late String controllerTag;

  @override
  void initState() {
    super.initState();

    // Ensure ChatViewModel exists
    if (!Get.isRegistered<ChatViewModel>()) {
      Get.put(ChatViewModel(), permanent: true);
    }
    // Get ChatViewModel and clear any lingering state
    final chatViewModel = Get.find<ChatViewModel>();
    // CRITICAL: Clear any previous chat state before setting new user
    chatViewModel.forceClearChatState();
    // Set selected user immediately
    chatViewModel.ensureUserSelected(widget.user);

    // Create unique tag for this specific chat instance
    controllerTag = 'chat_${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}';

    // Create new controller with unique tag
    controller = Get.put(
      ChattingViewController(
          user: widget.user,
          initialBlockedStatus: widget.isBlocked,
          initialBlockedByOtherStatus: widget.isBlockedByOther,
          initialDeletedStatus: widget.isDeleted
      ),
      tag: controllerTag,
    );
  }

  @override
  void dispose() {
    // CRITICAL: Clear chat state when disposing
    if (Get.isRegistered<ChatViewModel>()) {
      final chatViewModel = Get.find<ChatViewModel>();
      chatViewModel.forceClearChatState();
    }
    // Properly dispose controller
    if (Get.isRegistered<ChattingViewController>(tag: controllerTag)) {
      Get.delete<ChattingViewController>(tag: controllerTag, force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size chatMq = MediaQuery.of(context).size;

    return PopScope(
      canPop: !controller.showEmoji.value,
      onPopInvoked: (_) => controller.hideEmoji(),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          automaticallyImplyLeading: false,
          title: _buildAppBar(controller, chatMq),
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessagesList(controller, chatMq)),
            _buildUploadingIndicator(controller),
            _buildBottomSection(controller),
            _buildEmojiPicker(controller, chatMq),
          ],
        ),
      ),
    );
  }

  // Move all build methods here as instance methods
  Widget _buildAppBar(ChattingViewController controller, Size chatMq) {
    return Obx(() {
      final userData = controller.currentUserData;
      final hasBlockedThem = controller.isBlocked.value;
      final isBlockedByThem = controller.isBlockedByOther.value;
      final isDelete = controller.isDelete.value;

      return Row(
        children: [
          GestureDetector(
            onTap: controller.navigateBack,
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          // Only show user image if not blocked by them or deleted
          if (!isBlockedByThem && !isDelete && !hasBlockedThem)
            ClipRRect(
              borderRadius: BorderRadius.circular(chatMq.height * .3),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: chatMq.height * .05,
                width: chatMq.height * .05,
                imageUrl: controller.userImageUrl,
                errorWidget: (c, url, e) => Container(
                  height: chatMq.height * .05,
                  width: chatMq.height * .05,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(chatMq.height * .3),
                  ),
                  child: const Icon(
                    CupertinoIcons.person,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                placeholder: (c, url) => Container(
                  height: chatMq.height * .05,
                  width: chatMq.height * .05,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(chatMq.height * .3),
                  ),
                  child: const Icon(
                    CupertinoIcons.person,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ),
            ),
          // Add a placeholder if blocked or deleted
          if (isBlockedByThem || isDelete || hasBlockedThem)
            Container(
              height: chatMq.height * .05,
              width: chatMq.height * .05,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(chatMq.height * .3),
              ),
              child: const Icon(
                CupertinoIcons.person_fill, // Using person_fill for a more solid look
                color: Colors.grey,
                size: 30,
              ),
            ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (!isBlockedByThem && !isDelete && !hasBlockedThem)
                  Text(
                    userData.isOnline
                        ? 'Online'
                        : MyDateUtill.getLastActiveTime(
                      context: Get.context!,
                      lastActive: userData.lastActive,
                    ),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
          if (hasBlockedThem || isBlockedByThem || hasBlockedThem)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.block,
                color: Colors.red,
                size: 24,
              ),
            ),
        ],
      );
    });
  }



// In chatting_view.dart, fix the _buildMessagesList method:

// Update _buildMessagesList method in chatting_view.dart

// Update the _buildMessagesList method in chatting_view.dart to add spacing for reactions

  Widget _buildMessagesList(ChattingViewController controller, Size chatMq) {
    return Obx(() {
      final messages = controller.cachedMessages;
      final isLoading = controller.isInitialLoading.value;
      final isTyping = controller.isOtherUserTyping.value;

      if (isLoading && messages.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (messages.isNotEmpty) {
        return Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                padding: EdgeInsets.only(
                  top: chatMq.height * .01,
                  bottom: 10, // Add bottom padding
                ),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (ctx, i) {
                  final message = messages[i];
                  final currentUserId = controller.useCase.getUserId().toString();
                  final isMe = currentUserId == message.fromId;
                  final currentUserAvatar = controller.currentUserProfile.value ?? AppConstants.profileImg;

                  // Check if message has reactions to add extra spacing
                  final hasReactions = message.reactions != null && message.reactions!.isNotEmpty;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: hasReactions ? 12.0 : 0.0, // Extra padding if reactions exist
                    ),
                    child: ProfessionalMessageCard(
                      message: message,
                      pause: controller.paused.value,
                      showUserAvatar: true,
                      currentUserId: currentUserId,
                      userAvatarUrl: isMe ? controller.currentUserImageUrl.value : controller.userImageUrl,
                      onReaction: (message, reaction) {
                        // Handle reaction
                      },
                      onReply: (message) {
                        controller._handleReply(message);
                      },
                    ),
                  );
                },
              ),
            ),
            // Typing indicator at the bottom, above input field
            if (isTyping)
              TypingIndicator(
                isVisible: isTyping,
                userName: controller.currentUserData.name,
                userAvatarUrl: controller.userImageUrl,
              ),
          ],
        );
      }

      return _buildEmptyState(controller);
    });
  }
  Widget _buildEmptyState(ChattingViewController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.emptyStateIcon,
            size: 80,
            color: controller.emptyStateIconColor,
          ),
          const SizedBox(height: 20),
          Text(
            controller.emptyStateMessage,
            style: TextStyle(
              fontSize: 18,
              color: controller.emptyStateTextColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (controller.emptyStateSubtitle.isNotEmpty)
            Text(
              controller.emptyStateSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          if (!controller.isAnyBlocked) ...[
            TextButton(
              onPressed: controller.sendHiMessage,
              child: const Text(
                'Say Hi! 👋',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadingIndicator(ChattingViewController controller) {
    return Obx(() => controller.uploading.value
        ? const Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    )
        : const SizedBox.shrink());
  }

  Widget _buildBottomSection(ChattingViewController controller) {
    return Obx(() {
      return controller.isAnyBlocked
          ? _buildBlockContainer(controller)
          // : _buildChatInput(controller);
          : _buildChatInputWithReply(controller);
    });
  }

  // Replace your existing _buildChatInput method in chatting_view.dart with this:
// Enhanced chat input widget
  Widget _buildChatInputWithReply(ChattingViewController controller) {
    final Size chatMq = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        vertical: chatMq.height * .01,
        horizontal: chatMq.width * .025,
      ),
      child: Column(
        children: [
          // Reply preview
          Obx(() {
            if (controller.replyingTo.value == null) return const SizedBox.shrink();

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: AppColors.secondaryColor,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    color: AppColors.secondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.replyPreview.value,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: controller._clearReply,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Input row
          Row(
            children: [
              // Attachment button
              GestureDetector(
                onTap: controller.showImageOptions,
                // onTap: controller.showImageOptions,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    // Icons.attach_file_rounded,
                    color: AppColors.secondaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: chatMq.width * .02),
                      Expanded(
                        child: TextField(
                          controller: controller.textController,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onTap: controller.onTextFieldTap,
                          decoration: InputDecoration(
                            hintText: controller.replyingTo.value != null
                                ? 'Type your reply...'
                                : 'Write here ...',
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blackColor.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.toggleEmoji,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.emoji_emotions_rounded,
                            color: AppColors.blackColor.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: chatMq.width * .01),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // Send button
              GestureDetector(
                onTap: controller._sendMessageWithReply, // Use new method
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: AppColors.secondaryColor,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildChatInput(ChattingViewController controller) {
    final Size chatMq = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        vertical: chatMq.height * .01,
        horizontal: chatMq.width * .025,
      ),
      child: Row(
        children: [
          // Add Image Attachment Button Here
          GestureDetector(
            onTap: controller.showImageOptions,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.attach_file_rounded, // or Icons.image_rounded
                color: AppColors.secondaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(width: chatMq.width * .02),
                  Expanded(
                    child: TextField(
                      key: ValueKey('chat_input_${controllerTag}'),
                      controller: controller.textController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: controller.onTextFieldTap,
                      decoration: InputDecoration(
                        hintText: 'Write here ...',
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.toggleEmoji,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.emoji_emotions_rounded,
                        color: AppColors.blackColor.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: chatMq.width * .01),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Send Button
          _buildSendButton(controller),
        ],
      ),
    );
  }

  Widget _buildSendButton(ChattingViewController controller) {
    return GestureDetector(
      onTap: controller.sendMessage,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.send,
          color: AppColors.secondaryColor,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildBlockContainer(ChattingViewController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block, color: AppColors.redColor, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: AppText(
              text: controller.blockMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker(ChattingViewController controller, Size chatMq) {
    return Obx(() => controller.showEmoji.value
        ? SizedBox(
      height: chatMq.height * .35,
      child: EmojiPicker(
        textEditingController: controller.textController,
        config: Config(
          bottomActionBarConfig: const BottomActionBarConfig(
            showBackspaceButton: false,
            backgroundColor: Color(0xFFEBEFF2),
            buttonColor: Color(0xFFEBEFF2),
            buttonIconColor: Colors.blue,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: Colors.grey.shade100,
            buttonIconColor: Colors.black,
          ),
          categoryViewConfig: const CategoryViewConfig(
            tabBarHeight: 50,
          ),
          emojiTextStyle: const TextStyle(
            color: Colors.black,
          ),
          emojiViewConfig: EmojiViewConfig(
            columns: 9,
            recentsLimit: 50,
            verticalSpacing: 1,
            emojiSizeMax: 31 * (Platform.isIOS ? 1.30 : 1.0),
            loadingIndicator: const CircularProgressIndicator(),
          ),
        ),
      ),
    )
        : const SizedBox.shrink());
  }
}


// Helper extension for navigation with block status
extension ChattingViewNavigation on ChattingView {
  static Future<void> navigateWithBlockStatus({
    required ChatUser user,
    required ChatViewModel chatController,
  }) async {
    final results = await Future.wait([
      chatController.isUserBlocked(user.id),
      chatController.isBlockedByFriend(user.id),
    ]);

    Get.to(() => ChattingView(
      user: user,
      isBlocked: results[0],
      isBlockedByOther: results[1],
    ));
  }
}