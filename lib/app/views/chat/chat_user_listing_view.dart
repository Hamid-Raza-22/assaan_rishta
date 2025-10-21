// chat_user_listing_view.dart - Fixed with proper refresh mechanism

import 'package:assaan_rishta/app/core/services/firebase_service/export.dart';
import 'package:assaan_rishta/app/core/utils/screen_security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/chat_repository.dart';
import '../../utils/exports.dart';
import '../../viewmodels/chat_list_viewmodel.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../widgets/chat_user_card.dart';


class ChatUserListingView extends StatefulWidget {
  const ChatUserListingView({super.key});

  @override
  State<ChatUserListingView> createState() => _ChatUserListingViewState();
}

class _ChatUserListingViewState extends State<ChatUserListingView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  final chatController = Get.find<ChatViewModel>();
  late final ChatListController listController;

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    
    // Enable screen security (block screenshots & recording)
    ScreenSecurity.enableScreenSecurity();
    
    WidgetsBinding.instance.addObserver(this);

    // Initialize or get existing controller
    if (!Get.isRegistered<ChatListController>()) {
      listController = Get.put(ChatListController(), permanent: true);
    } else {
      listController = Get.find<ChatListController>();
    }

    // Initialize on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (FirebaseService.me == null) {
        await chatController.initSelf();
      }

      // Ensure streams are active
      listController.ensureStreamsActive();
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed - checking chat list streams');
      _handleAppResume();
      // Ensure streams are active when app resumes
     await listController.ensureStreamsActive();
    } else if (state == AppLifecycleState.paused) {
      debugPrint('📱 App paused');
    }
  }
  void _handleAppResume() async {
    debugPrint('📱 App resumed from background');

    try {
      // Update Firebase app state
      FirebaseService.setAppState(isInForeground: true);

      // Update user online status
      if (FirebaseService.me != null) {
        await FirebaseService.updateActiveStatus(true);
      }

      // If we're in a chat, mark undelivered messages
      if (Get.isRegistered<ChatViewModel>()) {
        final chatViewModel = Get.find<ChatViewModel>();
        if (chatViewModel.selectedUser.value != null) {
          final selectedUserId = chatViewModel.selectedUser.value!.id;

          // Mark any undelivered messages as delivered
          final chatRepository = ChatRepository();
          await chatRepository.markMessagesAsDelivered(selectedUserId);

          debugPrint('✅ Marked undelivered messages as delivered for: $selectedUserId');
        }
      }

      // Reset any stuck navigation states
      if (Get.isRegistered<ChatListController>()) {
        final controller = Get.find<ChatListController>();
        controller.resetAllStates();
      }

    } catch (e) {
      debugPrint('❌ Error handling app resume: $e');
    }
  }
  @override
  void dispose() {
    // Disable screen security when leaving chat list
    ScreenSecurity.disableScreenSecurity();
    
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
   super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        // Don't show loading if navigating to chat
        if (listController.isNavigatingToChat.value) {
          // Show current list instead of blank
          return _buildChatList();
        }

        if (listController.isLoading.value && listController.chatUsers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildChatList();
      }),
    );
  }
  Widget _buildChatList() {
    final users = listController.isSearching.value
        ? listController.searchResults
        : listController.chatUsers;

    if (users.isEmpty) {
      // Try to reconnect if empty
      if (!listController.isLoading.value && !listController.isRefreshing.value) {
        listController.ensureStreamsActive();
      }
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        listController.forceRefresh();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        key: PageStorageKey('chat_list_${listController.currentUserId}'),
        itemCount: users.length,
        padding: const EdgeInsets.only(top: 8),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemBuilder: (context, index) {
          final user = users[index];
          return RepaintBoundary(
            child: EnhancedChatUserCard(
              key: ValueKey('card_${user.id}_${listController.currentUserId}'),
              currentUID: listController.currentUserId,
              user: user,
            ),
          );
        },
      ),
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

