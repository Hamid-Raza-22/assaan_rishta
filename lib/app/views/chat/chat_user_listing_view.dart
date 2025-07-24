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
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final chatController = Get.find<ChatViewModel>();
  late final ChatListController listController;
  final FocusNode searchFocus = FocusNode();

  // ADDED: Keep alive to maintain state
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize controllers
    if (Get.isRegistered<ChatListController>()) {
      listController = Get.find<ChatListController>();
    } else {
      listController = Get.put(ChatListController());
    }

    // Initialize chat
    Future(() async => await chatController.initSelf());

    // Check for notifications
    _checkForNotificationNavigation();

    // ADDED: Listen for app lifecycle changes
    _setupLifecycleListener();
  }

  // ADDED: Setup lifecycle listener for better state management
  void _setupLifecycleListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh when view becomes active
      if (mounted) {
        listController.forceRefresh();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // ADDED: Refresh when app resumes
    if (state == AppLifecycleState.resumed && mounted) {
      debugPrint('📱 App resumed - refreshing chat list');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          listController.forceRefresh();
        }
      });
    }
  }

  void _checkForNotificationNavigation() {
    if (chatController.notificationUser != null) {
      chatController.handlePendingNavigation();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        chatController.handlePendingNavigation();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        // ADDED: Pull to refresh functionality
        onRefresh: () async {
          debugPrint('🔄 Pull to refresh triggered');
          listController.forceRefresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Obx(() {
          if (listController.isLoading.value && listController.chatUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = listController.isSearching.value
              ? listController.searchResults
              : listController.chatUsers;

          if (users.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            key: ValueKey('${users.length}_${DateTime.now().millisecondsSinceEpoch}'),
            itemCount: users.length,
            padding: const EdgeInsets.only(top: 8),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemBuilder: (context, index) {
              final user = users[index];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _buildChatItem(user),
              );
            },
          );
        }),
      ),
    );
  }

  // ADDED: Better empty state
  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        listController.forceRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  listController.isSearching.value
                      ? 'No users found'
                      : 'No chats yet!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (!listController.isSearching.value)
                  Text(
                    'Start a conversation',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatUser user) {
    return GestureDetector(
      onLongPress: () async {
        final isBlocked = await chatController.isUserBlocked(user.id);
        if (mounted) {
          showBlockUnblockBottomSheet(
            context: context,
            userId: user.id,
            isBlocked: isBlocked,
            onBlock: () async => await chatController.blockUser(user.id),
            onUnblock: () async => await chatController.unblockUser(user.id),
          );
        }
      },
      child: Dismissible(
        key: ValueKey(user.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Chat'),
              content: Text('Delete chat with ${user.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) => listController.deleteChat(user),
        child: ChatUserCard(
          key: ValueKey('card_${user.id}'),
          currentUID: listController.currentUserId,
          user: user,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.whiteColor,
      title: Obx(() => listController.isSearching.value
          ? TextField(
        focusNode: searchFocus,
        autofocus: true,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search name or email',
        ),
        style: const TextStyle(fontSize: 17),
        onChanged: listController.searchUsers,
      )
          : const Text('Chats')),
      centerTitle: true,
      actions: [
        // ADDED: Refresh button
        IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            debugPrint('🔄 Manual refresh triggered');
            listController.forceRefresh();
          },
          icon: const Icon(Icons.refresh),
        ),
        Obx(() => IconButton(
          tooltip: 'Search',
          onPressed: () {
            listController.toggleSearch();
            if (listController.isSearching.value) {
              searchFocus.requestFocus();
            }
          },
          icon: Icon(
            listController.isSearching.value
                ? CupertinoIcons.clear_circled
                : Icons.search,
          ),
        )),
      ],
    );
  }
}