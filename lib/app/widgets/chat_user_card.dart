// chat_user_card.dart - Fixed to hide online status for blocked users

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/export.dart';
import '../utils/exports.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../views/chat/export.dart';
import 'export.dart';

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
    if (!Get.isRegistered<ChatViewModel>()) {
      Get.put(ChatViewModel());
      debugPrint('💬 ChatViewModel created in _navigateToChat');
    }

    final controller = Get.find<ChatListController>();
    final chatViewModel = Get.find<ChatViewModel>();
    final size = MediaQuery.of(context).size;

    // Check if blocked - both ways
    final RxBool isBlockedByOther = false.obs;
    final RxBool hasBlockedThem = false.obs;

    // Check block status
    chatViewModel.isBlockedByFriend(user.id).then((value) {
      isBlockedByOther.value = value;
    });

    chatViewModel.isUserBlocked(user.id).then((value) {
      hasBlockedThem.value = value;
    });

    return Dismissible(
      key: Key('dismissible_${user.id}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) => _showDeleteConfirmDialog(context),
      onDismissed: (direction) {
        controller.deleteChat(user);
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
          onTap: () => _navigateToChat(context),
          onLongPress: () => _showBlockOptions(context),
          child: Obx(() {
            // If current user has blocked them, use static data instead of stream
            if (hasBlockedThem.value) {
              return ListTile(
                leading: _buildStaticAvatar(),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: _buildSubtitle(controller, isBlockedByOther.value),
                trailing: _buildTrailing(controller, context, isBlockedByOther.value),
              );
            }

            // Otherwise, use the stream for real-time updates
            return StreamBuilder(
              stream: chatViewModel.getUserInfoStream(user.id),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                // Use real-time data if available, otherwise fallback to cached data
                final displayUser = list.isNotEmpty ? list[0] : user;

                return ListTile(
                  leading: _buildAvatar(isBlockedByOther.value, displayUser),
                  title: Text(
                    displayUser.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: _buildSubtitle(controller, isBlockedByOther.value),
                  trailing: _buildTrailing(controller, context, isBlockedByOther.value),
                );
              },
            );
          }),
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

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) async {
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

  // Static avatar for blocked users (no online status)
  Widget _buildStaticAvatar() {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey[300],
      foregroundImage: provider(),
      child: user.image.isEmpty
          ? const Icon(
        Icons.person,
        color: Colors.grey,
        size: 30,
      )
          : null,
    );
  }

  Widget _buildAvatar(bool isBlockedByOther, [ChatUser? displayUser]) {
    final userToDisplay = displayUser ?? user;

    return Stack(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          foregroundImage: isBlockedByOther ? null : provider(userToDisplay),
          child: isBlockedByOther
              ? const Icon(
            Icons.person,
            color: Colors.grey,
            size: 30,
          )
              : null,
        ),
        // Only show online indicator if not blocked and user is online
        if (!isBlockedByOther && userToDisplay.isOnline)
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

  Widget _buildSubtitle(ChatListController controller, bool isBlockedByOther) {
    if (isBlockedByOther) {
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

  Widget _buildTrailing(ChatListController controller, BuildContext context, bool isBlockedByOther) {
    return Obx(() {
      final lastMessage = controller.getLastMessageReactive(user.id).value;

      if (lastMessage == null) return const SizedBox.shrink();

      final isUnread = lastMessage.read.isEmpty && lastMessage.fromId != currentUID;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isBlockedByOther)
            Text(
              MyDateUtill.getLastMessageTime(context, lastMessage.sent),
              style: TextStyle(
                fontSize: 12,
                color: isUnread ? Colors.green : Colors.grey,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          if (isUnread && !isBlockedByOther) ...[
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
          if (isBlockedByOther)
            const Icon(
              Icons.block,
              color: Colors.red,
              size: 20,
            ),
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

  void _navigateToChat(BuildContext context) {
    if (!Get.isRegistered<ChatViewModel>()) {
      Get.put(ChatViewModel());
      debugPrint('💬 ChatViewModel was not registered, now created.');
    } else if (Get.isPrepared<ChatViewModel>() && Get.isRegistered<ChatViewModel>()) {
      debugPrint('💬 ChatViewModel is already available.');
    }

    final chatController = Get.find<ChatViewModel>();

    chatController.setInsideChatStatus(true);

    Get.to(() => ChattingView(user: user))?.then((_) {
      chatController.setInsideChatStatus(false);
    });
  }

  void _showBlockOptions(BuildContext context) async {
    final chatController = Get.find<ChatViewModel>();
    final isBlocked = await chatController.isUserBlocked(user.id);

    if (context.mounted) {
      showBlockUnblockBottomSheet(
        context: context,
        userId: user.id,
        isBlocked: isBlocked,
        onBlock: () async {
          await chatController.blockUser(user.id);
          Get.back(); // Close chat if open
        },
        onUnblock: () async => await chatController.unblockUser(user.id),
      );
    }
  }
}