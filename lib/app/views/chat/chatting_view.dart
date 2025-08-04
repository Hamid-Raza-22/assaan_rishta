// Optimized ChattingView with instant block status display
// chatting_view.dart

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/export.dart';
import '../../domain/export.dart';
import '../../utils/exports.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/chat_list_viewmodel.dart';
import '../../widgets/export.dart';
import '../bottom_nav/export.dart';

// State Management Controller for ChattingView
class ChattingViewController extends GetxController with WidgetsBindingObserver {
  final ChatUser user;
  final bool? initialBlockedStatus;
  final bool? initialBlockedByOtherStatus;

  ChattingViewController({
    required this.user,
    this.initialBlockedStatus,
    this.initialBlockedByOtherStatus,
  });

  // Dependencies
  final useCase = Get.find<UserManagementUseCase>();
  final chatController = Get.find<ChatViewModel>();
  final chatListController = Get.find<ChatListController>();

  // Text controller
  late TextEditingController textController;

  // Observable states
  final showEmoji = false.obs;
  final uploading = false.obs;
  final paused = false.obs;
  late final RxBool isBlocked;
  late final RxBool isBlockedByOther;
  final isInitialLoading = true.obs;
  final showLoading = false.obs;

  // Messages and user data
  final cachedMessages = <Message>[].obs;
  final cachedUserData = Rx<ChatUser?>(null);

  // Stream subscriptions
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription? _userStreamSubscription;

  String currentUID = "";

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    currentUID = useCase.getUserId().toString();
    textController = TextEditingController();

    // Initialize block status with passed values or false
    isBlocked = (initialBlockedStatus ?? false).obs;
    isBlockedByOther = (initialBlockedByOtherStatus ?? false).obs;

    _initializeChat();
  }

  @override
  void onClose() {
    chatController.exitChat();
    chatController.setInsideChatStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    textController.dispose();
    _messagesSubscription?.cancel();
    _userStreamSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        chatController.setInsideChatStatus(true, chatUserId: user.id);

        paused.value = false;
        _markMessagesAsRead(cachedMessages);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        chatController.setInsideChatStatus(false);
        paused.value = true;
        break;
    }
  }

  // Initialize chat with proper loading states
  Future<void> _initializeChat() async {
    // Immediately show cached messages if available
    if (chatController.cachedMessagesPerUser.containsKey(user.id)) {
      cachedMessages.value = chatController.cachedMessagesPerUser[user.id]!;
    }

    // Set chat status first
    chatController.setInsideChatStatus(true, chatUserId: user.id);
    chatController.checkDeletionRecord();

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
        cachedMessages.value = messages;

        // Save in controller-level cache
        chatController.cachedMessagesPerUser[user.id] = messages;

        if (isInitialLoading.value) {
          debugPrint('✅ Message stream delivered. Turning off loading.');
          isInitialLoading.value = false;
        }

        if (!paused.value) {
          _markMessagesAsRead(messages);
        }
      });
    } catch (e) {
      debugPrint('Error initializing messages stream: $e');
      isInitialLoading.value = false;
    }
  }

  void _markMessagesAsRead(List<Message> messages) {
    if (messages.isEmpty) return;

    // Use a single batch operation for better performance
    Future.delayed(const Duration(milliseconds: 300), () {
      final unreadMessages = messages
          .where((msg) => msg.fromId != currentUID && msg.read.isEmpty)
          .toList();

      for (var message in unreadMessages) {
        chatController.markMessageAsRead(message);
      }
    });
  }

  // Message sending methods
  Future<void> sendMessage() async {
    final message = textController.text.trim();
    if (message.isNotEmpty) {
      textController.clear();

      // Check if this is first message
      if (cachedMessages.isEmpty) {
        await createUserChat(message);
      } else {
        checkChatUser();
        await chatController.sendMessage(message);
      }
    }
  }

  Future<void> sendHiMessage() async {
    await createUserChat('Hi! 👋');
  }

  Future<void> createUserChat(String firstMsg) async {
    bool isAdded = await chatController.addChatUser(user.id);
    if (isAdded) {
      chatController.selectedUser.value = user;
      await chatController.sendFirstMessage(firstMsg);
    }
  }

  void checkChatUser() {
    unawaited(chatController.addChatUser(user.id));
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
  void navigateBack() {
    if (Navigator.of(Get.context!).canPop()) {
      Get.back();
    } else {
      Get.offAll(() => const BottomNavView(index: 2));
    }
  }

  // Getters for computed values
  ChatUser get currentUserData => cachedUserData.value ?? user;

  bool get isAnyBlocked => isBlocked.value || isBlockedByOther.value;

  String get userImageUrl => currentUserData.image.isNotEmpty
      ? currentUserData.image
      : AppConstants.profileImg;

  String get blockMessage => isBlockedByOther.value
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
class ChattingView extends StatelessWidget {
  final ChatUser user;
  final bool? isBlocked;
  final bool? isBlockedByOther;

  const ChattingView({
    super.key,
    required this.user,
    this.isBlocked,
    this.isBlockedByOther,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with user data and block status
    final controller = Get.put(
      ChattingViewController(
        user: user,
        initialBlockedStatus: isBlocked,
        initialBlockedByOtherStatus: isBlockedByOther,
      ),
      tag: user.id,
    );

    // chatting_view.dart - Updated UI components with better empty state handling

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

  Widget _buildAppBar(ChattingViewController controller, Size chatMq) {
    return Obx(() {
      final userData = controller.currentUserData;
      final hasBlockedThem = controller.isBlocked.value;
      final isBlockedByThem = controller.isBlockedByOther.value;

      return Row(
        children: [
          GestureDetector(
            onTap: controller.navigateBack,
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
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
                if (!isBlockedByThem)
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
          if (hasBlockedThem || isBlockedByThem)
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

  // FIXED: Better messages list with improved empty state
  Widget _buildMessagesList(ChattingViewController controller, Size chatMq) {
    return Obx(() {
      final messages = controller.cachedMessages;
      final isLoading = controller.isInitialLoading.value;

      // Show loading indicator only on first load without cached data
      if (isLoading && messages.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Show messages if available
      if (messages.isNotEmpty) {
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          padding: EdgeInsets.only(top: chatMq.height * .01),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (ctx, i) => MessageCard(
            message: messages[i],
            pause: controller.paused.value,
          ),
        );
      }

      // Show appropriate empty state
      return _buildEmptyState(controller);
    });
  }

  // FIXED: Smarter empty state that distinguishes between different scenarios
// FIXED: Updated empty state without "Show All Messages" button
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

          // REMOVED: Show All Messages button functionality
          // Only show "Say Hi" button for non-blocked chats
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
          : _buildChatInput(controller);
    });
  }

  Widget _buildChatInput(ChattingViewController controller) {
    final Size chatMq = MediaQuery.of(Get.context!).size;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        vertical: chatMq.height * .01,
        horizontal: chatMq.width * .025,
      ),
      child: Row(
        children: [
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