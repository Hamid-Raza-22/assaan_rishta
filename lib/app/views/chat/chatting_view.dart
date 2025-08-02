// Optimized ChattingView with better state management and caching
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

class ChattingView extends StatefulWidget {
  final ChatUser user;

  const ChattingView({super.key, required this.user});

  @override
  State<ChattingView> createState() => _ChattingViewState();
}

class _ChattingViewState extends State<ChattingView>
    with WidgetsBindingObserver {
  final useCase = Get.find<UserManagementUseCase>();
  final chatController = Get.find<ChatViewModel>();
  final chatListController = Get.find<ChatListController>();

  late TextEditingController _textController;
  final RxBool _showEmoji = false.obs;
  final RxBool _uploading = false.obs;
  final RxBool _paused = false.obs;
  final RxBool isBlocked = false.obs;
  final RxBool isBlockedByOther = false.obs;

  // Improved loading state management
  final RxBool _isInitialLoading = true.obs;
  final RxBool _isBlockStatusLoaded = false.obs;
  final RxBool _showLoading = false.obs;

  final RxList<Message> _cachedMessages = <Message>[].obs;
  StreamSubscription<List<Message>>? _messagesSubscription;

  // Cache for user data
  final Rx<ChatUser?> _cachedUserData = Rx<ChatUser?>(null);
  StreamSubscription? _userStreamSubscription;

  String currentUID = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentUID = useCase.getUserId().toString();
    _textController = TextEditingController();

    // Initialize everything in parallel
    _initializeChat();
  }

  // Initialize chat with proper loading states
  Future<void> _initializeChat() async {
    isBlocked.value = false;
    isBlockedByOther.value = false;
    _isBlockStatusLoaded.value = true;
    // Immediately show cached messages if available
    if (chatController.cachedMessagesPerUser.containsKey(widget.user.id)) {
      _cachedMessages.value = chatController.cachedMessagesPerUser[widget.user.id]!;
    }

    // Set chat status first
    chatController.setInsideChatStatus(true, chatUserId: widget.user.id);
    chatController.checkDeletionRecord();

    // Start all operations in parallel
    // Start all operations
     await _checkBlockStatus();
    _initializeMessagesStream();
    _initializeUserStream();
  }

  // Check both block statuses with loading state
  Future<void> _checkBlockStatus() async {
    try {
      final results = await Future.wait([
        chatController.isUserBlocked(widget.user.id),
        chatController.isBlockedByFriend(widget.user.id),
      ]);

      isBlocked.value = results[0];
      isBlockedByOther.value = results[1];
       //_isBlockStatusLoaded.value = true;
    } catch (e) {
      debugPrint('Error checking block status: $e');
      //_isBlockStatusLoaded.value = true;
      isBlocked.value = false;
      isBlockedByOther.value = false;
    }
  }

  // Initialize user data stream
  void _initializeUserStream() {
    try {
      _userStreamSubscription = chatController
          .getUserInfoStream(widget.user.id)
          .listen((snapshot) {
        final data = snapshot.docs;
        if (data.isNotEmpty) {
          _cachedUserData.value = ChatUser.fromJson(data.first.data());

          // Update block status if user data changes
          if (_isBlockStatusLoaded.value) {
            _checkBlockStatus();
          }
        }
      });
    } catch (e) {
      debugPrint('Error initializing user stream: $e');
    }
  }

  void _initializeMessagesStream() {
    try {
      if (chatController.cachedMessagesPerUser.containsKey(widget.user.id)) {
        _cachedMessages.value = chatController.cachedMessagesPerUser[widget.user.id]!;
        _isInitialLoading.value = false;
      }

      _messagesSubscription = chatController
          .getFilteredMessagesStream(widget.user)
          .listen((messages) {
        _cachedMessages.value = messages;

        // Save in controller-level cache
        chatController.cachedMessagesPerUser[widget.user.id] = messages;

        if (_isInitialLoading.value && _isBlockStatusLoaded.value) {
          debugPrint('✅ Message stream delivered. Turning off loading.');
          _isInitialLoading.value = false;
        }

        if (!_paused.value) {
          _markMessagesAsRead(messages);
        }
      });

    } catch (e) {
      debugPrint('Error initializing messages stream: $e');
      _isInitialLoading.value = false;
    }
  }

  @override
  void dispose() {
    chatController.exitChat();
    chatController.setInsideChatStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _messagesSubscription?.cancel();
    _userStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        chatController.setInsideChatStatus(true, chatUserId: widget.user.id);
        _paused.value = false;
        // Mark messages as read when app resumes
        _markMessagesAsRead(_cachedMessages);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        chatController.setInsideChatStatus(false);
        _paused.value = true;
        break;
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

  @override
  Widget build(BuildContext context) {
    Size chatMq = MediaQuery.of(context).size;

    return PopScope(
      canPop: !_showEmoji.value,
      onPopInvoked: (_) {
        if (_showEmoji.value) {
          _showEmoji.value = false;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          automaticallyImplyLeading: false,
          title: _buildAppBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                // Only show loading if we have no messages at all (initial load)
                if (_cachedMessages.isEmpty && _showLoading.value&& !_isBlockStatusLoaded.value) {
                  return const Center(child: CircularProgressIndicator());
                }


                final messages = _cachedMessages;
                final blocked = isBlocked.value || isBlockedByOther.value;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          blocked
                              ? Icons.block_rounded
                              : chatController.currentChatDeletionTime.value != null
                              ? Icons.restart_alt
                              : Icons.chat_bubble_outline,
                          size: 80,
                          color: blocked ? Colors.red[300] : Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          blocked
                              ? isBlockedByOther.value
                              ? 'You can no longer message this user'
                              : 'You have blocked this user'
                              : chatController.currentChatDeletionTime.value != null
                              ? 'Chat history cleared'
                              : 'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: blocked ? Colors.red[700] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!blocked)
                          Text(
                            chatController.currentChatDeletionTime.value != null
                                ? 'Send a message to start fresh'
                                : 'Start the conversation',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (!blocked)
                          TextButton(
                            onPressed: () async {
                              await createUserChat('Hi! 👋');
                            },
                            child: const Text(
                              'Say Hi! 👋',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: EdgeInsets.only(top: chatMq.height * .01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (ctx, i) => MessageCard(
                    message: messages[i],
                    pause: _paused.value,
                  ),
                );
              }),
            ),
            Obx(() => _uploading.value
                ? const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : const SizedBox.shrink()),
            Obx(() {
              // Show loading while checking block status
              if (!_isBlockStatusLoaded.value) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                );
              }

              return (isBlocked.value || isBlockedByOther.value)
                  ? _buildBlockContainer()
                  : _buildChatInput();
            }),
            Obx(() => _showEmoji.value
                ? _buildEmojiPicker(chatMq)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    Size chatMq = MediaQuery.of(context).size;

    return Obx(() {
      // Use cached user data if available
      final userData = _cachedUserData.value ?? widget.user;
      final hasBlockedThem = isBlocked.value;
      final isBlockedByThem = isBlockedByOther.value;

      // Get image URL with proper validation
      String imageUrl = userData.image.isNotEmpty
          ? userData.image
          : AppConstants.profileImg;

      return Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (Navigator.of(context).canPop()) {
                Get.back();
              } else {
                Get.offAll(() => const BottomNavView(index: 2));
              }
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(chatMq.height * .3),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              height: chatMq.height * .05,
              width: chatMq.height * .05,
              imageUrl: imageUrl,
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
                if (!isBlockedByThem && _isBlockStatusLoaded.value)
                  Text(
                    userData.isOnline
                        ? 'Online'
                        : MyDateUtill.getLastActiveTime(
                      context: context,
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
          // Show block icon if either party has blocked
          if ((hasBlockedThem || isBlockedByThem) && _isBlockStatusLoaded.value)
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

  Widget _buildChatInput() {
    Size chatMq = MediaQuery.of(context).size;

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
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji.value) {
                          _showEmoji.value = false;
                        }
                      },
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
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _showEmoji.value = !_showEmoji.value;
                    },
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
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: () async {
        final message = _textController.text.trim();
        if (message.isNotEmpty) {
          _textController.clear();

          // Check if this is first message
          if (_cachedMessages.isEmpty) {
            await createUserChat(message);
          } else {
            checkChatUser();
            await chatController.sendMessage(message);
          }
        }
      },
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

  Widget _buildBlockContainer() {
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
              text: isBlockedByOther.value
                  ? "You can no longer message this user"
                  : "You have blocked this user",

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker(Size chatMq) {
    return SizedBox(
      height: chatMq.height * .35,
      child: EmojiPicker(
        textEditingController: _textController,
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
    );
  }

  Future<void> createUserChat(String firstMsg) async {
    bool isAdded = await chatController.addChatUser(widget.user.id);
    if (isAdded) {
      chatController.selectedUser.value = widget.user;
      await chatController.sendFirstMessage(firstMsg);
    }
  }

  void checkChatUser() {
    unawaited(chatController.addChatUser(widget.user.id));
  }
}