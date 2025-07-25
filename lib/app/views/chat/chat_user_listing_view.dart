// chat_user_listing_view.dart - Fixed with proper refresh mechanism

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/export.dart';
import '../../utils/exports.dart';
import '../../viewmodels/chat_list_viewmodel.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../widgets/chat_user_card.dart';
import 'export.dart';

class ChatUserListingView extends StatefulWidget {
  const ChatUserListingView({super.key});

  @override
  State<ChatUserListingView> createState() => _ChatUserListingViewState();
}

class _ChatUserListingViewState extends State<ChatUserListingView>
    with WidgetsBindingObserver {

  final chatController = Get.find<ChatViewModel>();
  late final ChatListController listController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    listController = Get.put(ChatListController());

    // Initialize once
    Future(() async {
      await chatController.initSelf();
      // No need for manual refresh - real-time updates handle everything
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reconnect listeners when app resumes
      listController.reconnectListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (listController.isLoading.value && listController.chatUsers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = listController.isSearching.value
            ? listController.searchResults
            : listController.chatUsers;

        if (users.isEmpty) {
          return _buildEmptyState();
        }

        // No RefreshIndicator needed - real-time updates
        return ListView.builder(
          // Important: Use a stable key
          key: PageStorageKey('chat_list_${listController.currentUserId}'),
          itemCount: users.length,
          padding: const EdgeInsets.only(top: 8),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final user = users[index];
// Use ValueKey with user ID for stability
            return RepaintBoundary(
              child: ChatUserCard(
                key: ValueKey('card_${user.id}_${listController.currentUserId}'),
                currentUID: listController.currentUserId,
                user: user,
              ),
            );
          },
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.whiteColor,
      title: Obx(() => listController.isSearching.value
          ? TextField(
        autofocus: true,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search name or email',
        ),
        onChanged: listController.searchUsers,
      )
          : const Text('Chats')),
      centerTitle: true,
      actions: [
        Obx(() => IconButton(
          onPressed: listController.toggleSearch,
          icon: Icon(
            listController.isSearching.value
                ? CupertinoIcons.clear_circled
                : Icons.search,
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No chats yet!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
  // Widget _buildChatItem(ChatUser user) {
  //   return GestureDetector(
  //     onLongPress: () async {
  //       final isBlocked = await chatController.isUserBlocked(user.id);
  //       if (mounted) {
  //         showBlockUnblockBottomSheet(
  //           context: context,
  //           userId: user.id,
  //           isBlocked: isBlocked,
  //           onBlock: () async => await chatController.blockUser(user.id),
  //           onUnblock: () async => await chatController.unblockUser(user.id),
  //         );
  //       }
  //     },
  //     child: Dismissible(
  //       key: ValueKey(user.id),
  //       direction: DismissDirection.endToStart,
  //       background: Container(
  //         color: Colors.red,
  //         alignment: Alignment.centerRight,
  //         padding: const EdgeInsets.symmetric(horizontal: 20),
  //         child: const Icon(Icons.delete, color: Colors.white),
  //       ),
  //       confirmDismiss: (direction) async {
  //         return await showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: const Text('Delete Chat'),
  //             content: Text('Delete chat with ${user.name}?'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context, false),
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context, true),
  //                 child: const Text('Delete', style: TextStyle(color: Colors.red)),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //       onDismissed: (direction) => listController.deleteChat(user),
  //       child: ChatUserCard(
  //         key: ValueKey('card_${user.id}'),
  //         currentUID: listController.currentUserId,
  //         user: user,
  //       ),
  //     ),
  //   );
  // }

  // PreferredSizeWidget _buildAppBar() {
  //   return AppBar(
  //     backgroundColor: AppColors.whiteColor,
  //     surfaceTintColor: AppColors.whiteColor,
  //     title: Obx(() => listController.isSearching.value
  //         ? TextField(
  //       focusNode: searchFocus,
  //       autofocus: true,
  //       textAlign: TextAlign.center,
  //       decoration: const InputDecoration(
  //         border: InputBorder.none,
  //         hintText: 'Search name or email',
  //       ),
  //       style: const TextStyle(fontSize: 17),
  //       onChanged: listController.searchUsers,
  //     )
  //         : const Text('Chats')),
  //     centerTitle: true,
  //     actions: [
  //       // ADDED: Refresh button
  //       IconButton(
  //         tooltip: 'Refresh',
  //         onPressed: () {
  //           debugPrint('🔄 Manual refresh triggered');
  //           listController.forceRefresh();
  //         },
  //         icon: const Icon(Icons.refresh),
  //       ),
  //       Obx(() => IconButton(
  //         tooltip: 'Search',
  //         onPressed: () {
  //           listController.toggleSearch();
  //           if (listController.isSearching.value) {
  //             searchFocus.requestFocus();
  //           }
  //         },
  //         icon: Icon(
  //           listController.isSearching.value
  //               ? CupertinoIcons.clear_circled
  //               : Icons.search,
  //         ),
  //       )),
  //     ],
  //   );
  // }
