
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

  List<Message> _list = [];
  late TextEditingController _textController;

  bool _showEmoji = false;
  bool _uploading = false;
  bool _paused = false;
  String currentUID = "";
  bool isBlocked = false;

  // Update these methods in chatting_view.dart:

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentUID = useCase.getUserId().toString();
    _textController = TextEditingController();

    // Set inside chat status to true when entering chat
    chatController.setInsideChatStatus(true);

    // Mark messages as read
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    // Set inside chat status to false when leaving chat
    chatController.setInsideChatStatus(false);

    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        chatController.setInsideChatStatus(true);
        if (mounted) setState(() => _paused = false);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        chatController.setInsideChatStatus(false);
        if (mounted) setState(() => _paused = true);
        break;
    }
  }

// Add this method to mark messages as read
  void _markMessagesAsRead() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_list.isNotEmpty) {
        for (var message in _list) {
          if (message.fromId != currentUID && message.read.isEmpty) {
            chatController.markMessageAsRead(message);
          }
        }
      }
    });
  }
  void change() => setState(() => _showEmoji = !_showEmoji);

  _willpop() {
    if (_showEmoji) {
      change();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size chatMq = MediaQuery.of(context).size;
    return PopScope(
      canPop: !_showEmoji,
      onPopInvoked: (_) => _willpop(),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          automaticallyImplyLeading: false,
          title: _appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: chatController.getAllMessagesStream(widget.user),
                builder: (ctx, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: Text(
                          'Syncing ...',
                          style: TextStyle(fontSize: 25, color: Colors.black54),
                        ),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: _list.length,
                          padding: EdgeInsets.only(top: chatMq.height * .01),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (ctx, i) => MessageCard(
                            message: _list[i],
                            pause: _paused,
                          ),
                        );
                      } else {
                        return Center(
                          child: TextButton(
                            onPressed: () async {
                              await createUserChat('Hii! 👋');
                            },
                            child: const Text(
                              'Say Hii! 👋',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
            if (_uploading)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            isBlocked ? getBlockContainer() : _chatInput(),
            if (_showEmoji) _emojiPicker(chatMq),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    Size chatMq = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: chatController.getUserInfoStream(widget.user.id),
      builder: (context, snapshot) {
        final data = snapshot.data?.docs;
        final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
        isBlocked = list.isNotEmpty ? list[0].blockedUsers.contains(currentUID) : false;

        return Row(
          children: [
            GestureDetector(
              onTap: () {
                debugPrint('🔙 Back button pressed from ${widget.user.name}');

                // Smart back navigation
                if (Navigator.of(context).canPop() && Get.previousRoute.isNotEmpty) {
                  debugPrint('📤 Can pop - doing normal back');
                  Get.back();
                } else {

                  debugPrint('🏠 Cannot pop - going to chat list');
                  Get.to(() => const BottomNavView(index: 1));
                }
              },
              child: const Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(chatMq.height * .3),
              child: CachedNetworkImage(
                fit: chatMq.width <= 500 ? BoxFit.fill : null,
                height: chatMq.width <= 500 ? chatMq.height * .055 : chatMq.height * .045,
                width: chatMq.width <= 500 ? chatMq.height * .055 : chatMq.height * .045,
                imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                errorWidget: (c, url, e) => Image.network(AppConstants.profileImg),
                placeholder: (c, url) => const Icon(size: 30, CupertinoIcons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
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
                ),
                const SizedBox(height: 3),
                Text(
                  list.isNotEmpty
                      ? list[0].isOnline
                      ? 'Online'
                      : MyDateUtill.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                      : MyDateUtill.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _chatInput() {
    Size chatMq = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: chatController.getUserInfoStream(widget.user.id),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          isBlocked = list.isNotEmpty
              ? list[0].blockedUsers.contains(currentUID)
              : false;

          return isBlocked
              ? getBlockContainer()
              : Container(
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
                                  autofocus: false,
                                  controller: _textController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  // readOnly: _sending,
                                  onTap: () => _showEmoji
                                      ? setState(() => _showEmoji = !_showEmoji)
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: 'Write here ...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blackColor
                                          .withAlpha( (0.5 * 255).round()),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (FocusManager
                                      .instance.primaryFocus!.hasFocus) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  }
                                  setState(() => _showEmoji = !_showEmoji);
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
                                    color: AppColors.blackColor
                                        .withAlpha( (0.5 * 255).round()),
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
                      getSendBtn(),
                    ],
                  ),
                );
        });
  }

  Widget _emojiPicker(Size chatMq) {
    return SizedBox(
      height: chatMq.height * .35,
      child: EmojiPicker(
        textEditingController: _textController,
        config: Config(
          // checkPlatformCompatibility: false,
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
            //showBackspaceButton: true,
            tabBarHeight: 50,
          ),
          emojiTextStyle: const TextStyle(
            // fontFamily: fonFam,
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

  Widget getSendBtn() {
    return GestureDetector(
      onTap: () async {
        if (_textController.text.isNotEmpty) {
          String sendMessageVal = _textController.text;
          _textController.clear();
          if (_list.isEmpty) {
            await createUserChat(sendMessageVal);
          } else {
            checkChatUser();
            await chatController.sendMessage(sendMessageVal);
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

  Widget getBlockContainer() {
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
