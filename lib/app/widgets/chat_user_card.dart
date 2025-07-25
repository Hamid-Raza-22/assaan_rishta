// chat_user_card.dart - Fixed blinking issue

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
    final controller = Get.find<ChatListController>();
    final size = MediaQuery.of(context).size;

    return Card(
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
        child: ListTile(
          leading: _buildAvatar(),
          title: Text(
            user.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Obx(() => _buildSubtitle(controller)),
          trailing: Obx(() => _buildTrailing(controller, context)),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.transparent,
          foregroundImage: user.image.isEmpty
              ? const NetworkImage(AppConstants.profileImg)
              : NetworkImage(user.image),
        ),
        if (user.isOnline)
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

  Widget _buildSubtitle(ChatListController controller) {
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
  }

  Widget _buildTrailing(ChatListController controller, BuildContext context) {
    final lastMessage = controller.getLastMessageReactive(user.id).value;

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
    final chatController = Get.find<ChatViewModel>();
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
        onBlock: () async => await chatController.blockUser(user.id),
        onUnblock: () async => await chatController.unblockUser(user.id),
      );
    }
  }
}