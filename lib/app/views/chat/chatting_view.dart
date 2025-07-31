// Fixed ChattingView with optimized loading
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

  // Add these variables to manage loading state
  final RxBool _isInitialLoading = true.obs;
  final RxList<Message> _cachedMessages = <Message>[].obs;
  StreamSubscription<List<Message>>? _messagesSubscription;

  String currentUID = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentUID = useCase.getUserId().toString();
    _textController = TextEditingController();

    // Set chat status and check deletion
    chatController.setInsideChatStatus(true, chatUserId: widget.user.id);
    chatController.checkDeletionRecord();

    // Initialize messages stream
    _initializeMessagesStream();
  }

  void _initializeMessagesStream() {
    _messagesSubscription = chatController
        .getFilteredMessagesStream(widget.user)
        .listen((messages) {
      _cachedMessages.value = messages;
      if (_isInitialLoading.value) {
        _isInitialLoading.value = false;
      }

      // Mark messages as read
      _markMessagesAsRead(messages);
    });
  }

  @override
  void dispose() {
    chatController.exitChat();
    chatController.setInsideChatStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        chatController.setInsideChatStatus(true, chatUserId: widget.user.id);
        _paused.value = false;
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
    Future.delayed(const Duration(milliseconds: 500), () {
      for (var message in messages) {
        if (message.fromId != currentUID && message.read.isEmpty) {
          chatController.markMessageAsRead(message);
        }
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
                // Show loading only on initial load
                if (_isInitialLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = _cachedMessages;

                if (messages.isEmpty) {
                  return Obx(() => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          chatController.currentChatDeletionTime.value != null
                              ? Icons.restart_alt
                              : Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          chatController.currentChatDeletionTime.value != null
                              ? 'Chat history cleared'
                              : 'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                  ));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: EdgeInsets.only(top: chatMq.height * .01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (ctx, i) => Obx(() => MessageCard(
                    message: messages[i],
                    pause: _paused.value,
                  )),
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
            Obx(() => isBlocked.value ? _buildBlockContainer() : _buildChatInput()),
            Obx(() => _showEmoji.value ? _buildEmojiPicker(chatMq) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    Size chatMq = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: chatController.getUserInfoStream(widget.user.id),
      builder: (context, snapshot) {
        final data = snapshot.data?.docs;
        final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

        // FIXED: Update isBlocked after build completes
        if (list.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            isBlocked.value = list[0].blockedUsers.contains(currentUID);
          });
        }

        return Row(
          children: [
            GestureDetector(
              onTap: () async {
                // Ensure proper cleanup before navigation
                //await chatController.exitChat();
                if (Navigator.of(context).canPop()) {
                  Get.back();
                } else {
                  //await chatController.exitChat();
                  Get.to(() => const BottomNavView(index: 2));
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
                imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                errorWidget: (c, url, e) => Image.network(AppConstants.profileImg),
                placeholder: (c, url) => const Icon(
                  size: 30,
                  CupertinoIcons.person,
                  color: Colors.white,
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
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                        ? 'Online'
                        : MyDateUtill.getLastActiveTime(
                      context: context,
                      lastActive: list[0].lastActive,
                    )
                        : MyDateUtill.getLastActiveTime(
                      context: context,
                      lastActive: widget.user.lastActive,
                    ),
                    style: const TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
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
          if (chatController.messages.isEmpty) {
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
      padding: const EdgeInsets.only(bottom: 40),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, color: AppColors.redColor),
          SizedBox(width: 10),
          AppText(text: "You can no longer message this user."),
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