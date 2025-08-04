// chat_user_card.dart - FIXED: Block status listeners to match actual Firestore structure

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/export.dart';
import '../utils/exports.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../views/chat/export.dart';
import 'export.dart';

// Controller for managing ChatUserCard state
class ChatUserCardController extends GetxController {
  final String userId;
  final String currentUID;
  final ChatUser user;

  ChatUserCardController({
    required this.userId,
    required this.currentUID,
    required this.user,
  });

  late final ChatListController listController;
  late final ChatViewModel chatViewModel;

  final RxBool isBlockedByOther = false.obs;
  final RxBool hasBlockedThem = false.obs;
  final RxBool isBlockStatusLoaded = false.obs;

  StreamSubscription? _userStreamSubscription;
  StreamSubscription? _blockStatusSubscription;
  StreamSubscription? _blockedByOtherSubscription;

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<ChatViewModel>()) {
      Get.put(ChatViewModel());
      debugPrint('💬 ChatViewModel created in ChatUserCard');
    }

    listController = Get.find<ChatListController>();
    chatViewModel = Get.find<ChatViewModel>();

    // Check block status once on init
    _checkBlockStatus();

    // Setup real-time listeners for block status
    _setupBlockStatusListeners();
  }

  @override
  void onClose() {
    // Cancel all subscriptions first
    _userStreamSubscription?.cancel();
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();

    // Clear references
    _userStreamSubscription = null;
    _blockStatusSubscription = null;
    _blockedByOtherSubscription = null;

    super.onClose();
  }

  Future<void> _checkBlockStatus() async {
    try {
      final results = await Future.wait([
        chatViewModel.isBlockedByFriend(userId),
        chatViewModel.isUserBlocked(userId),
      ]);

      isBlockedByOther.value = results[0];
      hasBlockedThem.value = results[1];
      isBlockStatusLoaded.value = true;

      debugPrint('🔍 Block status checked - BlockedByOther: ${isBlockedByOther.value}, HasBlockedThem: ${hasBlockedThem.value}');

      // Only setup stream if not blocked
      if (!hasBlockedThem.value && !isBlockedByOther.value) {
        _setupUserStream();
      }
    } catch (e) {
      debugPrint('Error checking block status: $e');
      isBlockStatusLoaded.value = true;
    }
  }

  // FIXED: Listen to the correct Firestore structure
  void _setupBlockStatusListeners() {
    // Cancel any existing subscriptions first
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();

    // FIXED: Listen to the main user document's blockedUsers field (not subcollection)
    _blockStatusSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
        .doc(currentUID)
        .snapshots()
        .listen(
          (snapshot) {
        // Check if controller is still registered
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          return;
        }

        if (!snapshot.exists) return;

        final userData = snapshot.data();
        final blockedUsers = userData?['blockedUsers'] as Map<String, dynamic>? ?? {};

        final wasBlocked = hasBlockedThem.value;
        hasBlockedThem.value = blockedUsers.containsKey(userId);

        debugPrint('📱 Block status updated - User $userId blocked by me: ${hasBlockedThem.value}');

        // Force UI update when unblocking
        if (wasBlocked && !hasBlockedThem.value) {
          debugPrint('🔓 User unblocked, forcing UI update');
          Future.delayed(const Duration(milliseconds: 100), () {
            update(); // Force GetX to rebuild
          });
        }

        // Update stream based on block status
        if (hasBlockedThem.value) {
          _userStreamSubscription?.cancel();
          _userStreamSubscription = null;
        } else if (!isBlockedByOther.value) {
          _setupUserStream();
        }
      },
      onError: (error) {
        debugPrint('Error in block status stream: $error');
      },
      cancelOnError: false,
    );

    // FIXED: Listen to other user's main document blockedUsers field
    _blockedByOtherSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
        // Check if controller is still registered
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          return;
        }

        if (!snapshot.exists) return;

        final userData = snapshot.data();
        final blockedUsers = userData?['blockedUsers'] as Map<String, dynamic>? ?? {};

        final wasBlockedByOther = isBlockedByOther.value;
        isBlockedByOther.value = blockedUsers.containsKey(currentUID);

        debugPrint('👤 Blocked by other status updated - User $userId blocked me: ${isBlockedByOther.value}');

        // Force UI update when other user unblocks
        if (wasBlockedByOther && !isBlockedByOther.value) {
          debugPrint('🔓 Unblocked by other user, forcing UI update');
          Future.delayed(const Duration(milliseconds: 100), () {
            update(); // Force GetX to rebuild
          });
        }

        // Update stream based on block status
        if (isBlockedByOther.value) {
          _userStreamSubscription?.cancel();
          _userStreamSubscription = null;
        } else if (!hasBlockedThem.value) {
          _setupUserStream();
        }
      },
      onError: (error) {
        debugPrint('Error in blocked by other stream: $error');
      },
      cancelOnError: false,
    );
  }

  void _setupUserStream() {
    // Cancel existing subscription
    _userStreamSubscription?.cancel();
    _userStreamSubscription = null;

    // Only setup stream if not blocked and controller is still registered
    if (!hasBlockedThem.value && !isBlockedByOther.value &&
        Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {

      debugPrint('📺 Setting up user stream for $userId');

      _userStreamSubscription = chatViewModel
          .getUserInfoStream(userId)
          .listen((snapshot) {
        // Check if controller is still registered before updating
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          _userStreamSubscription?.cancel();
          _userStreamSubscription = null;
          return;
        }

        if (snapshot.docs.isNotEmpty) {
          debugPrint('👤 User data updated for $userId');
          // Force UI update when user data changes
          update();
        }
      });
    }
  }

  Future<void> handleBlock() async {
    debugPrint('🚫 Blocking user $userId');
    await chatViewModel.blockUser(userId);
    // Cancel stream when blocking
    _userStreamSubscription?.cancel();
    _userStreamSubscription = null;

    // Force immediate UI update
    hasBlockedThem.value = true;
    update();
  }

  Future<void> handleUnblock() async {
    debugPrint('✅ Unblocking user $userId');
    await chatViewModel.unblockUser(userId);

    // Force immediate UI update
    hasBlockedThem.value = false;
    update();

    // Re-setup stream when unblocking with a small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!hasBlockedThem.value && !isBlockedByOther.value) {
        _setupUserStream();
      }
    });
  }

  // Helper method to get current block status
  bool get isCurrentlyBlocked => hasBlockedThem.value || isBlockedByOther.value;
}

class ChatUserCard extends StatelessWidget {
  final String currentUID;
  final ChatUser user;

  const ChatUserCard({
    super.key,
    required this.user,
    required this.currentUID,
  });

  @override
  Widget build(BuildContext context) {
    // Create unique controller for this card
    final String tag = 'chat_card_${user.id}';

    if (!Get.isRegistered<ChatUserCardController>(tag: tag)) {
      Get.put(
        ChatUserCardController(
          userId: user.id,
          currentUID: currentUID,
          user: user,
        ),
        tag: tag,
      );
    }

    final controller = Get.find<ChatUserCardController>(tag: tag);
    final size = MediaQuery.of(context).size;

    return Dismissible(
      key: Key('dismissible_${user.id}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) => _showDeleteConfirmDialog(context, controller),
      onDismissed: (direction) {
        // Clean up controller first before deleting chat
        if (Get.isRegistered<ChatUserCardController>(tag: tag)) {
          Get.delete<ChatUserCardController>(tag: tag, force: true);
        }
        controller.listController.deleteChat(user);
      },
      child: Card(
        key: ValueKey('chat_card_${user.id}'),
        color: const Color(0xFFF6F6F6),
        margin: EdgeInsets.symmetric(
          horizontal: size.width * .03,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () => _navigateToChat(context, controller),
          onLongPress: () => _showBlockOptions(context, controller),
          child: GetBuilder<ChatUserCardController>(
            tag: tag,
            builder: (ctrl) {
              return Obx(() {
                final isBlocked = ctrl.isCurrentlyBlocked;

                debugPrint('🎯 Building UI for ${user.id} - isBlocked: $isBlocked, hasBlockedThem: ${ctrl.hasBlockedThem.value}, isBlockedByOther: ${ctrl.isBlockedByOther.value}');

                // If blocked, show static data
                if (isBlocked) {
                  return ListTile(
                    leading: _buildBlockedAvatar(),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: _buildSubtitle(ctrl.listController, ctrl.isBlockedByOther.value),
                    trailing: _buildTrailing(
                        ctrl.listController,
                        context,
                        true
                    ),
                  );
                }

                // Only use stream for non-blocked users
                return StreamBuilder(
                  stream: ctrl.chatViewModel.getUserInfoStream(user.id),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.docs;
                    final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                    // Use real-time data if available, otherwise fallback to cached data
                    final displayUser = list.isNotEmpty ? list[0] : user;

                    return ListTile(
                      leading: _buildAvatar(false, displayUser),
                      title: Text(
                        displayUser.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: _buildSubtitle(ctrl.listController, false),
                      trailing: _buildTrailing(ctrl.listController, context, false),
                    );
                  },
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_forever,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, ChatUserCardController controller) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Delete Chat'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete your chat with ${user.name}?\n\nThis action cannot be undone and all messages will be permanently deleted.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Blocked avatar - completely hide image and show only icon
  Widget _buildBlockedAvatar() {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey[300],
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 30,
      ),
    );
  }

  Widget _buildAvatar(bool isBlocked, [ChatUser? displayUser]) {
    final userToDisplay = displayUser ?? user;

    return Stack(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          foregroundImage: isBlocked ? null : provider(userToDisplay),
          child: isBlocked || userToDisplay.image.isEmpty
              ? const Icon(
            Icons.person,
            color: Colors.grey,
            size: 30,
          )
              : null,
        ),
        // Only show online indicator if not blocked and user is online
        if (!isBlocked && userToDisplay.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  ImageProvider? provider([ChatUser? displayUser]) {
    final userToDisplay = displayUser ?? user;
    return userToDisplay.image.isEmpty
        ? const NetworkImage(AppConstants.profileImg)
        : NetworkImage(userToDisplay.image);
  }

  Widget _buildSubtitle(ChatListController controller, bool isBlocked) {
    if (isBlocked) {
      return const Text(
        'Account not available',
        style: TextStyle(fontSize: 14, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      );
    }

    return Obx(() {
      final lastMessage = controller.getLastMessageReactive(user.id).value;

      if (lastMessage == null) {
        return Text(
          user.about,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        );
      }

      final isMe = lastMessage.fromId == currentUID;

      if (lastMessage.type == Type.image) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe) _buildTickIcon(lastMessage.read.isNotEmpty),
            const Icon(Icons.image_rounded, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            const Text('Photo', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMe) _buildTickIcon(lastMessage.read.isNotEmpty),
          Flexible(
            child: Text(
              lastMessage.msg,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: lastMessage.read.isEmpty && !isMe
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTrailing(ChatListController controller, BuildContext context, bool isBlocked) {
    return Obx(() {
      final lastMessage = controller.getLastMessageReactive(user.id).value;

      // If blocked, show block icon prominently
      if (isBlocked) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              Icons.block,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(height: 2),
          ],
        );
      }

      if (lastMessage == null) return const SizedBox.shrink();

      final isUnread = lastMessage.read.isEmpty && lastMessage.fromId != currentUID;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            MyDateUtill.getLastMessageTime(context, lastMessage.sent),
            style: TextStyle(
              fontSize: 12,
              color: isUnread ? Colors.green : Colors.grey,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isUnread) ...[
            const SizedBox(height: 2),
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildTickIcon(bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(
        Icons.done_all_rounded,
        color: isRead ? Colors.blue : Colors.grey,
        size: 16,
      ),
    );
  }

  void _navigateToChat(BuildContext context, ChatUserCardController controller) async {
    if (!Get.isRegistered<ChatViewModel>()) {
      Get.put(ChatViewModel());
      debugPrint('💬 ChatViewModel was not registered, now created.');
    }

    final chatController = Get.find<ChatViewModel>();
    chatController.setInsideChatStatus(true);

    // Pre-fetch block status before navigation
    bool? isBlocked;
    bool? isBlockedByOther;

    try {
      // Fetch both block statuses in parallel
      final results = await Future.wait([
        chatController.isUserBlocked(user.id),
        chatController.isBlockedByFriend(user.id),
      ]);

      isBlocked = results[0];
      isBlockedByOther = results[1];
    } catch (e) {
      debugPrint('Error fetching block status: $e');
      // Continue with null values if error occurs
    }

    // Navigate with pre-fetched block status
    Get.to(() => ChattingView(
      user: user,
      isBlocked: isBlocked,
      isBlockedByOther: isBlockedByOther,
    ))?.then((_) {
      chatController.setInsideChatStatus(false);
    });
  }

  void _showBlockOptions(BuildContext context, ChatUserCardController controller) async {
    final chatController = Get.find<ChatViewModel>();
    final isBlocked = await chatController.isUserBlocked(user.id);

    if (context.mounted) {
      showBlockUnblockBottomSheet(
        context: context,
        userId: user.id,
        isBlocked: isBlocked,
        onBlock: () async {
          await controller.handleBlock();
        },
        onUnblock: () async {
          await controller.handleUnblock();
        },
      );
    }
  }
}