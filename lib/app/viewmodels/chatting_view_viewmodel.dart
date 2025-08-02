// // GetX Managed ChattingView with proper reactive state management
// // chatting_view.dart
//
// import 'dart:async';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../core/export.dart';
// import '../domain/export.dart';
// import '../utils/exports.dart';
// import '../views/bottom_nav/export.dart';
// import '../widgets/export.dart';
// import 'chat_list_viewmodel.dart';
// import 'chat_viewmodel.dart';
//
//
//
// // GetX Controller for ChattingView
// // Complete ChattingView with GetX Management
// // chatting_view.dart
//
// import 'dart:async';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
//
//
// // GetX Controller for ChattingView
// // Professional GetX State Management for ChattingView
// // chatting_view.dart
//
// import 'dart:async';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
//
//
// // Dedicated Controller for Chat View State
// class ChattingViewController extends GetxController with WidgetsBindingObserver {
//   final UserManagementUseCase useCase = Get.find<UserManagementUseCase>();
//   final ChatViewModel chatController = Get.find<ChatViewModel>();
//   final ChatListController chatListController = Get.find<ChatListController>();
//
//   // UI State Management
//   final Rx<ChatUser> _currentUser = ChatUser.empty().obs;
//   final RxBool showEmoji = false.obs;
//   final RxBool isUploading = false.obs;
//   final RxBool isPaused = false.obs;
//   final RxBool isBlocked = false.obs;
//   final RxBool isBlockedByOther = false.obs;
//
//   // Loading States
//   final RxBool isInitializing = true.obs;
//   final RxBool isBlockStatusLoading = true.obs;
//   final RxBool isMessagesLoading = true.obs;
//
//   // Data State
//   final RxList<Message> messages = <Message>[].obs;
//   final Rx<ChatUser?> cachedUserData = Rx<ChatUser?>(null);
//
//   // Controllers
//   late TextEditingController textController;
//
//   // Streams
//   StreamSubscription<List<Message>>? _messagesSubscription;
//   StreamSubscription? _userStreamSubscription;
//
//   // Getters
//   String get currentUID => useCase.getUserId().toString();
//   bool get canSendMessage => !isBlocked.value && !isBlockedByOther.value;
//   bool get showLoadingIndicator => isInitializing.value && messages.isEmpty;
//   ChatUser get displayUser => cachedUserData.value ?? _currentUser.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);
//     textController = TextEditingController();
//   }
//
//   @override
//   void onClose() {
//     _cleanup();
//     super.onClose();
//   }
//
//   // Initialize chat with user
//   Future<void> initializeChat(ChatUser user) async {
//     try {
//       _currentUser.value = user;
//       isInitializing.value = true;
//
//       // Set chat status
//       chatController.setInsideChatStatus(true, chatUserId: user.id);
//       chatController.checkDeletionRecord();
//
//       // Load cached messages immediately if available
//       _loadCachedMessages();
//
//       // Initialize streams and check status in parallel
//       await Future.wait([
//         _checkBlockStatus(),
//         _initializeStreams(),
//       ]);
//
//     } catch (e) {
//       debugPrint('Error initializing chat: $e');
//       _handleInitializationError();
//     } finally {
//       isInitializing.value = false;
//     }
//   }
//
//   // Load cached messages
//   void _loadCachedMessages() {
//     if (chatController.cachedMessagesPerUser.containsKey(_currentUser.value.id)) {
//       messages.value = chatController.cachedMessagesPerUser[_currentUser.value.id]!;
//       isMessagesLoading.value = false;
//     }
//   }
//
//   // Check block status
//   Future<void> _checkBlockStatus() async {
//     try {
//       isBlockStatusLoading.value = true;
//
//       final results = await Future.wait([
//         chatController.isUserBlocked(_currentUser.value.id),
//         chatController.isBlockedByFriend(_currentUser.value.id),
//       ]);
//
//       isBlocked.value = results[0];
//       isBlockedByOther.value = results[1];
//
//     } catch (e) {
//       debugPrint('Error checking block status: $e');
//       isBlocked.value = false;
//       isBlockedByOther.value = false;
//     } finally {
//       isBlockStatusLoading.value = false;
//     }
//   }
//
//   // Initialize streams
//   Future<void> _initializeStreams() async {
//     try {
//       await Future.wait([
//         _initializeUserStream(),
//         _initializeMessagesStream(),
//       ]);
//     } catch (e) {
//       debugPrint('Error initializing streams: $e');
//     }
//   }
//
//   // Initialize user data stream
//   Future<void> _initializeUserStream() async {
//     try {
//       _userStreamSubscription = chatController
//           .getUserInfoStream(_currentUser.value.id)
//           .listen(
//         _handleUserDataUpdate,
//         onError: (error) => debugPrint('User stream error: $error'),
//       );
//     } catch (e) {
//       debugPrint('Error initializing user stream: $e');
//     }
//   }
//
//   // Handle user data updates
//   void _handleUserDataUpdate(dynamic snapshot) {
//     try {
//       final data = snapshot.docs;
//       if (data.isNotEmpty) {
//         cachedUserData.value = ChatUser.fromJson(data.first.data());
//
//         // Refresh block status if needed
//         if (!isBlockStatusLoading.value) {
//           _checkBlockStatus();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error handling user data update: $e');
//     }
//   }
//
//   // Initialize messages stream
//   Future<void> _initializeMessagesStream() async {
//     try {
//       _messagesSubscription = chatController
//           .getFilteredMessagesStream(_currentUser.value)
//           .listen(
//         _handleMessagesUpdate,
//         onError: (error) => debugPrint('Messages stream error: $error'),
//       );
//     } catch (e) {
//       debugPrint('Error initializing messages stream: $e');
//       isMessagesLoading.value = false;
//     }
//   }
//
//   // Handle messages updates
//   void _handleMessagesUpdate(List<Message> newMessages) {
//     try {
//       messages.value = newMessages;
//
//       // Update cache
//       chatController.cachedMessagesPerUser[_currentUser.value.id] = newMessages;
//
//       // Update loading state
//       if (isMessagesLoading.value) {
//         isMessagesLoading.value = false;
//       }
//
//       // Mark messages as read if not paused
//       if (!isPaused.value) {
//         _markMessagesAsRead(newMessages);
//       }
//     } catch (e) {
//       debugPrint('Error handling messages update: $e');
//     }
//   }
//
//   // Mark messages as read
//   void _markMessagesAsRead(List<Message> messageList) {
//     if (messageList.isEmpty) return;
//
//     Future.delayed(const Duration(milliseconds: 300), () {
//       final unreadMessages = messageList
//           .where((msg) => msg.fromId != currentUID && msg.read.isEmpty)
//           .toList();
//
//       for (var message in unreadMessages) {
//         chatController.markMessageAsRead(message);
//       }
//     });
//   }
//
//   // Send message
//   Future<void> sendMessage() async {
//     final message = textController.text.trim();
//     if (message.isEmpty || !canSendMessage) return;
//
//     try {
//       textController.clear();
//
//       if (messages.isEmpty) {
//         await _createUserChat(message);
//       } else {
//         await _sendRegularMessage(message);
//       }
//     } catch (e) {
//       debugPrint('Error sending message: $e');
//       // Show error to user
//       Get.snackbar('Error', 'Failed to send message');
//     }
//   }
//
//   // Create new chat
//   Future<void> _createUserChat(String firstMsg) async {
//     try {
//       final isAdded = await chatController.addChatUser(_currentUser.value.id);
//       if (isAdded) {
//         chatController.selectedUser.value = _currentUser.value;
//         await chatController.sendFirstMessage(firstMsg);
//       }
//     } catch (e) {
//       debugPrint('Error creating user chat: $e');
//       rethrow;
//     }
//   }
//
//   // Send regular message
//   Future<void> _sendRegularMessage(String message) async {
//     try {
//       unawaited(chatController.addChatUser(_currentUser.value.id));
//       await chatController.sendMessage(message);
//     } catch (e) {
//       debugPrint('Error sending regular message: $e');
//       rethrow;
//     }
//   }
//
//   // Toggle emoji picker
//   void toggleEmojiPicker() {
//     showEmoji.value = !showEmoji.value;
//     if (showEmoji.value) {
//       FocusManager.instance.primaryFocus?.unfocus();
//     }
//   }
//
//   // Hide emoji picker
//   void hideEmojiPicker() {
//     if (showEmoji.value) {
//       showEmoji.value = false;
//     }
//   }
//
//   // Handle app lifecycle changes
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         _handleAppResumed();
//         break;
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.detached:
//       case AppLifecycleState.hidden:
//         _handleAppPaused();
//         break;
//     }
//   }
//
//   // Handle app resumed
//   void _handleAppResumed() {
//     chatController.setInsideChatStatus(true, chatUserId: _currentUser.value.id);
//     isPaused.value = false;
//     _markMessagesAsRead(messages);
//   }
//
//   // Handle app paused
//   void _handleAppPaused() {
//     chatController.setInsideChatStatus(false);
//     isPaused.value = true;
//   }
//
//   // Handle initialization error
//   void _handleInitializationError() {
//     isInitializing.value = false;
//     isMessagesLoading.value = false;
//     isBlockStatusLoading.value = false;
//   }
//
//   // Cleanup resources
//   void _cleanup() {
//     chatController.exitChat();
//     chatController.setInsideChatStatus(false);
//     WidgetsBinding.instance.removeObserver(this);
//     textController.dispose();
//     _messagesSubscription?.cancel();
//     _userStreamSubscription?.cancel();
//   }
//
//   // Navigation helper
//   void navigateBack() {
//     if (Navigator.of(Get.context!).canPop()) {
//       Get.back();
//     } else {
//       Get.offAll(() => const BottomNavView(index: 2));
//     }
//   }
// }
//
// // Optimized ChattingView Widget
// class ChattingView extends StatelessWidget {
//   final ChatUser user;
//
//   const ChattingView({super.key, required this.user});
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller with dependency injection
//     final controller = Get.put(ChattingViewController(), tag: user.id);
//
//     // Initialize chat when widget builds
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.initializeChat(user);
//     });
//
//     return PopScope(
//       canPop: !controller.showEmoji.value,
//       onPopInvoked: (_) => controller.hideEmojiPicker(),
//       child: Scaffold(
//         backgroundColor: AppColors.whiteColor,
//         appBar: AppBar(
//           backgroundColor: AppColors.whiteColor,
//           surfaceTintColor: AppColors.whiteColor,
//           automaticallyImplyLeading: false,
//           title: _buildAppBar(controller),
//         ),
//         body: Column(
//           children: [
//             Expanded(child: _buildMessagesList(controller)),
//             _buildUploadingIndicator(controller),
//             _buildInputArea(controller),
//             _buildEmojiPicker(controller),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAppBar(ChattingViewController controller) {
//     return Obx(() {
//       final userData = controller.displayUser;
//       final hasBlockedThem = controller.isBlocked.value;
//       final isBlockedByThem = controller.isBlockedByOther.value;
//       final isBlockStatusLoading = controller.isBlockStatusLoading.value;
//
//       return Row(
//         children: [
//           GestureDetector(
//             onTap: controller.navigateBack,
//             child: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           ),
//           _buildUserAvatar(userData),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildUserInfo(userData, isBlockedByThem, isBlockStatusLoading),
//           ),
//           if ((hasBlockedThem || isBlockedByThem) && !isBlockStatusLoading)
//             const Padding(
//               padding: EdgeInsets.only(right: 10),
//               child: Icon(Icons.block, color: Colors.red, size: 24),
//             ),
//         ],
//       );
//     });
//   }
//
//   Widget _buildUserAvatar(ChatUser userData) {
//     final chatMq = MediaQuery.of(Get.context!).size;
//     final imageUrl = userData.image.isNotEmpty ? userData.image : AppConstants.profileImg;
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(chatMq.height * .3),
//       child: CachedNetworkImage(
//         fit: BoxFit.cover,
//         height: chatMq.height * .05,
//         width: chatMq.height * .05,
//         imageUrl: imageUrl,
//         errorWidget: (c, url, e) => _buildAvatarPlaceholder(chatMq),
//         placeholder: (c, url) => _buildAvatarPlaceholder(chatMq),
//       ),
//     );
//   }
//
//   Widget _buildAvatarPlaceholder(Size chatMq) {
//     return Container(
//       height: chatMq.height * .05,
//       width: chatMq.height * .05,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(chatMq.height * .3),
//       ),
//       child: const Icon(CupertinoIcons.person, color: Colors.grey, size: 30),
//     );
//   }
//
//   Widget _buildUserInfo(ChatUser userData, bool isBlockedByThem, bool isBlockStatusLoading) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           userData.name,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 3),
//         if (!isBlockedByThem && !isBlockStatusLoading)
//           Text(
//             userData.isOnline
//                 ? 'Online'
//                 : MyDateUtill.getLastActiveTime(
//               context: Get.context!,
//               lastActive: userData.lastActive,
//             ),
//             style: const TextStyle(color: Colors.black54, fontSize: 15),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildMessagesList(ChattingViewController controller) {
//     return Obx(() {
//       if (controller.showLoadingIndicator) {
//         return const Center(child: CircularProgressIndicator());
//       }
//
//       final messages = controller.messages;
//       final blocked = controller.isBlocked.value || controller.isBlockedByOther.value;
//
//       if (messages.isEmpty) {
//         return _buildEmptyState(controller, blocked);
//       }
//
//       return ListView.builder(
//         reverse: true,
//         itemCount: messages.length,
//         padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).size.height * .01),
//         physics: const BouncingScrollPhysics(),
//         itemBuilder: (ctx, i) => MessageCard(
//           message: messages[i],
//           pause: controller.isPaused.value,
//         ),
//       );
//     });
//   }
//
//   Widget _buildEmptyState(ChattingViewController controller, bool blocked) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             blocked
//                 ? Icons.block_rounded
//                 : controller.chatController.currentChatDeletionTime.value != null
//                 ? Icons.restart_alt
//                 : Icons.chat_bubble_outline,
//             size: 80,
//             color: blocked ? Colors.red[300] : Colors.grey[400],
//           ),
//           const SizedBox(height: 20),
//           Text(
//             _getEmptyStateTitle(controller, blocked),
//             style: TextStyle(
//               fontSize: 18,
//               color: blocked ? Colors.red[700] : Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 10),
//           if (!blocked)
//             Text(
//               _getEmptyStateSubtitle(controller),
//               style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//             ),
//           const SizedBox(height: 20),
//           if (!blocked)
//             TextButton(
//               onPressed: () async {
//                 controller.textController.text = 'Hi! 👋';
//                 await controller.sendMessage();
//               },
//               child: const Text('Say Hi! 👋', style: TextStyle(fontSize: 24)),
//             ),
//         ],
//       ),
//     );
//   }
//
//   String _getEmptyStateTitle(ChattingViewController controller, bool blocked) {
//     if (blocked) {
//       return controller.isBlockedByOther.value
//           ? 'You can no longer message this user'
//           : 'You have blocked this user';
//     }
//
//     return controller.chatController.currentChatDeletionTime.value != null
//         ? 'Chat history cleared'
//         : 'No messages yet';
//   }
//
//   String _getEmptyStateSubtitle(ChattingViewController controller) {
//     return controller.chatController.currentChatDeletionTime.value != null
//         ? 'Send a message to start fresh'
//         : 'Start the conversation';
//   }
//
//   Widget _buildUploadingIndicator(ChattingViewController controller) {
//     return Obx(() => controller.isUploading.value
//         ? const Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//         child: CircularProgressIndicator(strokeWidth: 2),
//       ),
//     )
//         : const SizedBox.shrink());
//   }
//
//   Widget _buildInputArea(ChattingViewController controller) {
//     return Obx(() {
//       if (controller.isBlockStatusLoading.value) {
//         return const Padding(
//           padding: EdgeInsets.all(20.0),
//           child: CircularProgressIndicator(),
//         );
//       }
//
//       return controller.canSendMessage
//           ? _buildChatInput(controller)
//           : _buildBlockContainer(controller);
//     });
//   }
//
//   Widget _buildChatInput(ChattingViewController controller) {
//     final chatMq = MediaQuery.of(Get.context!).size;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: EdgeInsets.symmetric(
//         vertical: chatMq.height * .01,
//         horizontal: chatMq.width * .025,
//       ),
//       child: Row(
//         children: [
//           Expanded(child: _buildTextInputField(controller, chatMq)),
//           const SizedBox(width: 5),
//           _buildSendButton(controller),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextInputField(ChattingViewController controller, Size chatMq) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF2F2F5),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           SizedBox(width: chatMq.width * .02),
//           Expanded(
//             child: TextField(
//               controller: controller.textController,
//               textCapitalization: TextCapitalization.sentences,
//               keyboardType: TextInputType.multiline,
//               maxLines: null,
//               onTap: controller.hideEmojiPicker,
//               decoration: InputDecoration(
//                 hintText: 'Write here ...',
//                 hintStyle: GoogleFonts.poppins(
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.blackColor.withOpacity(0.5),
//                 ),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: controller.toggleEmojiPicker,
//             child: Container(
//               height: 30,
//               width: 30,
//               decoration: BoxDecoration(
//                 color: AppColors.whiteColor,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               alignment: Alignment.center,
//               child: Icon(
//                 Icons.emoji_emotions_rounded,
//                 color: AppColors.blackColor.withOpacity(0.5),
//                 size: 20,
//               ),
//             ),
//           ),
//           SizedBox(width: chatMq.width * .01),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSendButton(ChattingViewController controller) {
//     return GestureDetector(
//       onTap: controller.sendMessage,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF2F2F5),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Icon(
//           Icons.send,
//           color: AppColors.secondaryColor,
//           size: 28,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBlockContainer(ChattingViewController controller) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       margin: const EdgeInsets.only(bottom: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.block, color: AppColors.redColor, size: 20),
//           const SizedBox(width: 10),
//           Flexible(
//             child: Obx(() => AppText(
//               text: controller.isBlockedByOther.value
//                   ? "You can no longer message this user"
//                   : "You have blocked this user",
//             )),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmojiPicker(ChattingViewController controller) {
//     final chatMq = MediaQuery.of(Get.context!).size;
//
//     return Obx(() => controller.showEmoji.value
//         ? SizedBox(
//       height: chatMq.height * .35,
//       child: EmojiPicker(
//         textEditingController: controller.textController,
//         config: Config(
//           bottomActionBarConfig: const BottomActionBarConfig(
//             showBackspaceButton: false,
//             backgroundColor: Color(0xFFEBEFF2),
//             buttonColor: Color(0xFFEBEFF2),
//             buttonIconColor: Colors.blue,
//           ),
//           searchViewConfig: SearchViewConfig(
//             backgroundColor: Colors.grey.shade100,
//             buttonIconColor: Colors.black,
//           ),
//           categoryViewConfig: const CategoryViewConfig(tabBarHeight: 50),
//           emojiTextStyle: const TextStyle(color: Colors.black),
//           emojiViewConfig: EmojiViewConfig(
//             columns: 9,
//             recentsLimit: 50,
//             verticalSpacing: 1,
//             emojiSizeMax: 31 * (Platform.isIOS ? 1.30 : 1.0),
//             loadingIndicator: const CircularProgressIndicator(),
//           ),
//         ),
//       ),
//     )
//         : const SizedBox.shrink());
//   }
// }
//
//
//
