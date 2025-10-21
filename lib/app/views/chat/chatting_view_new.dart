// // ChattingView - Clean UI Layer
// // Displays chat interface using ChattingViewController
//
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../../core/export.dart';
// import '../../utils/exports.dart';
// import '../../viewmodels/chat_viewmodel.dart';
// import '../../widgets/export.dart';
// import '../../widgets/typing_indicator.dart';
// import 'chatting_controller.dart';
//
// /// Main Chat View - UI Only
// class ChattingView extends StatefulWidget {
//   final ChatUser user;
//   final bool? isBlocked;
//   final bool? isBlockedByOther;
//   final bool? isDeleted;
//
//   const ChattingView({
//     super.key,
//     required this.user,
//     this.isBlocked,
//     this.isBlockedByOther,
//     this.isDeleted,
//   });
//
//   @override
//   State<ChattingView> createState() => _ChattingViewState();
// }
//
// class _ChattingViewState extends State<ChattingView> {
//   late ChattingViewController controller;
//   late String controllerTag;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Ensure ChatViewModel exists
//     if (!Get.isRegistered<ChatViewModel>()) {
//       Get.put(ChatViewModel(), permanent: true);
//     }
//
//     // Clear any previous chat state
//     final chatViewModel = Get.find<ChatViewModel>();
//     chatViewModel.forceClearChatState();
//     chatViewModel.ensureUserSelected(widget.user);
//
//     // Create unique controller tag
//     controllerTag = 'chat_${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}';
//
//     // Initialize controller
//     controller = Get.put(
//       ChattingViewController(
//         user: widget.user,
//         initialBlockedStatus: widget.isBlocked,
//         initialBlockedByOtherStatus: widget.isBlockedByOther,
//         initialDeletedStatus: widget.isDeleted,
//       ),
//       tag: controllerTag,
//     );
//   }
//
//   @override
//   void dispose() {
//     // Clear chat state
//     if (Get.isRegistered<ChatViewModel>()) {
//       final chatViewModel = Get.find<ChatViewModel>();
//       chatViewModel.forceClearChatState();
//     }
//
//     // Dispose controller
//     if (Get.isRegistered<ChattingViewController>(tag: controllerTag)) {
//       Get.delete<ChattingViewController>(tag: controllerTag, force: true);
//     }
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size chatMq = MediaQuery.of(context).size;
//
//     return PopScope(
//       canPop: !controller.showEmoji.value && !controller.isSelectionMode.value,
//       onPopInvoked: (_) {
//         if (controller.isSelectionMode.value) {
//           controller.exitSelectionMode();
//         } else {
//           controller.hideEmoji();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.whiteColor,
//         appBar: AppBar(
//           backgroundColor: AppColors.whiteColor,
//           surfaceTintColor: AppColors.whiteColor,
//           automaticallyImplyLeading: false,
//           title: Obx(() => controller.isSelectionMode.value
//               ? _buildSelectionModeAppBar()
//               : _buildNormalAppBar(chatMq)),
//         ),
//         body: Column(
//           children: [
//             Expanded(child: _buildMessagesList(chatMq)),
//             _buildUploadingIndicator(),
//             Obx(() => controller.isSelectionMode.value
//                 ? _buildSelectionModeActions()
//                 : _buildBottomSection()),
//             _buildEmojiPicker(chatMq),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ========== App Bar Widgets ==========
//   Widget _buildSelectionModeAppBar() {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: controller.exitSelectionMode,
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Obx(() => Text(
//             controller.getSelectionCountText(),
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           )),
//         ),
//         IconButton(
//           icon: Icon(
//             controller.selectedMessages.length == controller.cachedMessages.length
//                 ? Icons.check_box
//                 : Icons.check_box_outline_blank,
//             color: Colors.black,
//           ),
//           onPressed: controller.selectedMessages.length == controller.cachedMessages.length
//               ? controller.deselectAllMessages
//               : controller.selectAllMessages,
//           tooltip: controller.selectedMessages.length == controller.cachedMessages.length
//               ? 'Deselect all'
//               : 'Select all',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNormalAppBar(Size chatMq) {
//     return Obx(() {
//       final userData = controller.currentUserData;
//       final hasBlockedThem = controller.isBlocked.value;
//       final isBlockedByThem = controller.isBlockedByOther.value;
//       final isDelete = controller.isDelete.value;
//
//       return Row(
//         children: [
//           GestureDetector(
//             onTap: controller.navigateBack,
//             child: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           ),
//           if (!isBlockedByThem && !isDelete && !hasBlockedThem)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(chatMq.height * .3),
//               child: controller.isValidNetworkUrl(controller.userImageUrl)
//                   ? CachedNetworkImage(
//                       fit: BoxFit.cover,
//                       height: chatMq.height * .05,
//                       width: chatMq.height * .05,
//                       imageUrl: controller.userImageUrl,
//                       fadeInDuration: const Duration(milliseconds: 0),
//                       fadeOutDuration: const Duration(milliseconds: 0),
//                       placeholder: (c, url) => Container(
//                         height: chatMq.height * .05,
//                         width: chatMq.height * .05,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(chatMq.height * .3),
//                         ),
//                       ),
//                       errorWidget: (c, url, e) => Container(
//                         height: chatMq.height * .05,
//                         width: chatMq.height * .05,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(chatMq.height * .3),
//                         ),
//                         child: const Icon(
//                           CupertinoIcons.person,
//                           color: Colors.grey,
//                           size: 30,
//                         ),
//                       ),
//                     )
//                   : Container(
//                       height: chatMq.height * .05,
//                       width: chatMq.height * .05,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(chatMq.height * .3),
//                       ),
//                       child: const Icon(
//                         CupertinoIcons.person,
//                         color: Colors.grey,
//                         size: 30,
//                       ),
//                     ),
//             ),
//           if (isBlockedByThem || isDelete || hasBlockedThem)
//             Container(
//               height: chatMq.height * .05,
//               width: chatMq.height * .05,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(chatMq.height * .3),
//               ),
//               child: const Icon(
//                 CupertinoIcons.person_fill,
//                 color: Colors.grey,
//                 size: 30,
//               ),
//             ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   userData.name,
//                   style: const TextStyle(
//                     color: Colors.black87,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 3),
//                 if (!isBlockedByThem && !isDelete && !hasBlockedThem)
//                   Text(
//                     userData.isOnline
//                         ? 'Online'
//                         : MyDateUtill.getLastActiveTime(
//                             context: context,
//                             lastActive: userData.lastActive,
//                           ),
//                     style: const TextStyle(
//                       color: Colors.black54,
//                       fontSize: 15,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           if (hasBlockedThem || isBlockedByThem)
//             const Padding(
//               padding: EdgeInsets.only(right: 10),
//               child: Icon(
//                 Icons.block,
//                 color: Colors.red,
//                 size: 24,
//               ),
//             ),
//         ],
//       );
//     });
//   }
//
//   // ========== Messages List Widget ==========
//   Widget _buildMessagesList(Size chatMq) {
//     return Obx(() {
//       final messages = controller.cachedMessages;
//       final isLoading = controller.isInitialLoading.value;
//       final isTyping = controller.isOtherUserTyping.value;
//       final isSelectionMode = controller.isSelectionMode.value;
//
//       if (isLoading && messages.isEmpty) {
//         return _buildChatShimmer();
//       }
//
//       if (messages.isNotEmpty) {
//         return Column(
//           children: [
//             Expanded(
//               child: NotificationListener<ScrollNotification>(
//                 onNotification: (ScrollNotification scrollInfo) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//                     controller.isKeyboardVisible.value = bottomInset > 0;
//                   });
//                   return false;
//                 },
//                 child: ListView.builder(
//                   controller: controller.scrollController,
//                   reverse: true,
//                   itemCount: messages.length,
//                   padding: EdgeInsets.only(
//                     top: chatMq.height * .01,
//                     bottom: 10,
//                   ),
//                   physics: const BouncingScrollPhysics(),
//                   keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//                   itemBuilder: (ctx, i) {
//                     final message = messages[i];
//                     final currentUserId = controller.useCase.getUserId().toString();
//                     final isMe = currentUserId == message.fromId;
//                     final hasReactions = message.reactions != null && message.reactions!.isNotEmpty;
//
//                     return Padding(
//                       padding: EdgeInsets.only(
//                         bottom: hasReactions ? 12.0 : 0.0,
//                       ),
//                       child: Obx(() => ProfessionalMessageCard(
//                         message: message,
//                         pause: controller.paused.value,
//                         showUserAvatar: true,
//                         currentUserId: currentUserId,
//                         userAvatarUrl: isMe
//                             ? controller.currentUserImageUrl.value
//                             : controller.userImageUrl,
//                         isSelected: controller.isMessageSelected(message),
//                         isSelectionMode: isSelectionMode,
//                         onSelectionToggle: controller.toggleMessageSelection,
//                         onMessageLongPress: (msg) {
//                           if (!isSelectionMode) {
//                             controller.enterSelectionMode(msg);
//                           }
//                         },
//                         onReaction: (message, reaction) {
//                           // Handle reaction
//                         },
//                         onReply: (message) {
//                           controller.handleReply(message);
//                         },
//                       )),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             if (isTyping)
//               TypingIndicator(
//                 isVisible: isTyping,
//                 userName: controller.currentUserData.name,
//                 userAvatarUrl: controller.userImageUrl,
//               ),
//           ],
//         );
//       }
//
//       return _buildEmptyState();
//     });
//   }
//
//   // ========== Shimmer Loading ==========
//   Widget _buildChatShimmer() {
//     final w = MediaQuery.sizeOf(context).width;
//     final h = MediaQuery.sizeOf(context).height;
//
//     return SizedBox.expand(
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         enabled: true,
//         child: ListView.builder(
//           reverse: true,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           itemCount: 16,
//           itemBuilder: (ctx, i) {
//             final isMe = i % 2 == 0;
//             final bubbleWidth = w * (isMe ? 0.58 : 0.68);
//             final showTimestamp = i % 5 == 0;
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 if (showTimestamp)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6.0),
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Container(
//                         width: 90,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Row(
//                     mainAxisAlignment:
//                         isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//                     children: [
//                       if (!isMe)
//                         Container(
//                           width: 34,
//                           height: h * .034,
//                           margin: const EdgeInsets.only(right: 8),
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       Container(
//                         constraints: BoxConstraints(maxWidth: bubbleWidth),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: const Radius.circular(16),
//                             topRight: const Radius.circular(16),
//                             bottomLeft: Radius.circular(isMe ? 16 : 4),
//                             bottomRight: Radius.circular(isMe ? 4 : 16),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               width: bubbleWidth * (0.6 + (i % 3) * 0.1),
//                               height: 10,
//                               color: Colors.white,
//                             ),
//                             const SizedBox(height: 6),
//                             if (i % 3 != 0)
//                               Container(
//                                 width: bubbleWidth * (0.4 + (i % 2) * 0.2),
//                                 height: 10,
//                                 color: Colors.white,
//                               ),
//                           ],
//                         ),
//                       ),
//                       if (isMe) const SizedBox(width: 8),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   // ========== Empty State Widget ==========
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             controller.emptyStateIcon,
//             size: 80,
//             color: controller.emptyStateIconColor,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             controller.emptyStateMessage,
//             style: TextStyle(
//               fontSize: 18,
//               color: controller.emptyStateTextColor,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           if (controller.emptyStateSubtitle.isNotEmpty)
//             Text(
//               controller.emptyStateSubtitle,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           const SizedBox(height: 20),
//           if (!controller.isAnyBlocked) ...[
//             TextButton(
//               onPressed: controller.sendHiMessage,
//               child: const Text(
//                 'Say Hi! 👋',
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ========== Selection Mode Actions ==========
//   Widget _buildSelectionModeActions() {
//     return Container(
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           IconButton(
//             onPressed: controller.copySelectedMessages,
//             icon: const Icon(Icons.copy),
//             tooltip: 'Copy',
//           ),
//           IconButton(
//             onPressed: controller.forwardSelectedMessages,
//             icon: const Icon(Icons.forward),
//             tooltip: 'Forward',
//           ),
//           Obx(() {
//             final hasOwnMessages = controller.selectedMessages
//                 .any((msg) => msg.fromId == controller.currentUID);
//             return IconButton(
//               onPressed: hasOwnMessages ? controller.deleteSelectedMessages : null,
//               icon: Icon(
//                 Icons.delete,
//                 color: hasOwnMessages ? Colors.red : Colors.grey,
//               ),
//               tooltip: 'Delete',
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   // ========== Bottom Section (Input/Block) ==========
//   Widget _buildBottomSection() {
//     return Obx(() {
//       return controller.isAnyBlocked
//           ? _buildBlockContainer()
//           : _buildChatInputWithReply();
//     });
//   }
//
//   Widget _buildBlockContainer() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       margin: const EdgeInsets.only(bottom: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.block, color: AppColors.redColor, size: 20),
//           const SizedBox(width: 10),
//           Flexible(
//             child: AppText(text: controller.blockMessage),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ========== Chat Input Widget ==========
//   Widget _buildChatInputWithReply() {
//     final Size chatMq = MediaQuery.of(context).size;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: EdgeInsets.symmetric(
//         vertical: chatMq.height * .01,
//         horizontal: chatMq.width * .025,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Reply preview
//           Obx(() {
//             if (controller.replyingTo.value == null) return const SizedBox.shrink();
//
//             return Container(
//               width: double.infinity,
//               margin: const EdgeInsets.only(bottom: 8),
//               constraints: BoxConstraints(
//                 maxHeight: chatMq.height * 0.15,
//                 minHeight: 50,
//               ),
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.secondaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border(
//                       left: BorderSide(
//                         color: AppColors.secondaryColor,
//                         width: 3,
//                       ),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.reply,
//                         color: AppColors.secondaryColor,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Replying to',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: AppColors.secondaryColor,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               controller.replyPreview.value,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: Colors.grey[700],
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: controller.clearReply,
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           child: Icon(
//                             Icons.close,
//                             size: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//
//           // Input row
//           Row(
//             children: [
//               // Attachment button
//               GestureDetector(
//                 onTap: controller.showImageOptions,
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF2F2F5),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.camera_alt,
//                     color: AppColors.secondaryColor,
//                     size: 24,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//
//               // Text input
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF2F2F5),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(width: chatMq.width * .02),
//                       Expanded(
//                         child: TextField(
//                           controller: controller.textController,
//                           textCapitalization: TextCapitalization.sentences,
//                           keyboardType: TextInputType.multiline,
//                           maxLines: null,
//                           onTap: controller.onTextFieldTap,
//                           decoration: InputDecoration(
//                             hintText: controller.replyingTo.value != null
//                                 ? 'Type your reply...'
//                                 : 'Write here ...',
//                             hintStyle: GoogleFonts.poppins(
//                               fontWeight: FontWeight.w400,
//                               color: AppColors.blackColor.withOpacity(0.5),
//                             ),
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: controller.toggleEmoji,
//                         child: Container(
//                           height: 30,
//                           width: 30,
//                           decoration: BoxDecoration(
//                             color: AppColors.whiteColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           alignment: Alignment.center,
//                           child: Icon(
//                             Icons.emoji_emotions_rounded,
//                             color: AppColors.blackColor.withOpacity(0.5),
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: chatMq.width * .01),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 5),
//
//               // Send button
//               GestureDetector(
//                 onTap: controller.sendMessageWithReply,
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF2F2F5),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.send,
//                     color: AppColors.secondaryColor,
//                     size: 28,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ========== Uploading Indicator ==========
//   Widget _buildUploadingIndicator() {
//     return Obx(() => controller.uploading.value
//         ? const Align(
//             alignment: Alignment.centerRight,
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//           )
//         : const SizedBox.shrink());
//   }
//
//   // ========== Emoji Picker ==========
//   Widget _buildEmojiPicker(Size chatMq) {
//     return Obx(() => controller.showEmoji.value
//         ? SizedBox(
//             height: chatMq.height * .35,
//             child: EmojiPicker(
//               textEditingController: controller.textController,
//               config: Config(
//                 bottomActionBarConfig: const BottomActionBarConfig(
//                   showBackspaceButton: false,
//                   backgroundColor: Color(0xFFEBEFF2),
//                   buttonColor: Color(0xFFEBEFF2),
//                   buttonIconColor: Colors.blue,
//                 ),
//                 searchViewConfig: SearchViewConfig(
//                   backgroundColor: Colors.grey.shade100,
//                   buttonIconColor: Colors.black,
//                 ),
//                 categoryViewConfig: const CategoryViewConfig(
//                   tabBarHeight: 50,
//                 ),
//                 emojiTextStyle: const TextStyle(
//                   color: Colors.black,
//                 ),
//                 emojiViewConfig: EmojiViewConfig(
//                   columns: 9,
//                   recentsLimit: 50,
//                   verticalSpacing: 1,
//                   emojiSizeMax: 31 * (Platform.isIOS ? 1.30 : 1.0),
//                   loadingIndicator: const CircularProgressIndicator(),
//                 ),
//               ),
//             ),
//           )
//         : const SizedBox.shrink());
//   }
// }
//
// // Helper extension for navigation with block status
// extension ChattingViewNavigation on ChattingView {
//   static Future<void> navigateWithBlockStatus({
//     required ChatUser user,
//     required ChatViewModel chatController,
//   }) async {
//     final results = await Future.wait([
//       chatController.isUserBlocked(user.id),
//       chatController.isBlockedByFriend(user.id),
//     ]);
//
//     Get.to(() => ChattingView(
//       user: user,
//       isBlocked: results[0],
//       isBlockedByOther: results[1],
//     ));
//   }
// }
