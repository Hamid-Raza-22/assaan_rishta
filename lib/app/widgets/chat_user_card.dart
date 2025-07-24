// chat_user_card.dart - Updated for instant message updates

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/export.dart';
import '../utils/exports.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../views/chat/export.dart';
import 'export.dart';

class ChatUserCard extends StatefulWidget {
  final String currentUID;
  final ChatUser user;

  const ChatUserCard({
    super.key,
    required this.user,
    required this.currentUID,
  });

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  final chatController = Get.find<ChatViewModel>();
  Message? _message;

  @override
  Widget build(BuildContext context) {
    Size mobileMq = MediaQuery.of(context).size;

    return Card(
      color: const Color(0xFFF6F6F6),
      margin: EdgeInsets.symmetric(horizontal: mobileMq.width * .03, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          debugPrint('📱 ChatUserCard tapped for user: ${widget.user.name}');

          // DIRECT NAVIGATION - Instant transition
          Get.to(() => ChattingView(user: widget.user))?.then((_) {
            chatController.setInsideChatStatus(false);
          });
        },
        child: StreamBuilder(
          stream: chatController.getLastMessage(widget.user),
          builder: (context, snapshot) {
            // INSTANT UPDATE: Update message state immediately when stream changes
            if (snapshot.hasData && snapshot.data != null) {
              _message = snapshot.data;
            }

            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.transparent,
                    foregroundImage: provider(),
                  ),
                  if (widget.user.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: greenCircle(),
                    ),
                ],
              ),
              title: Text(
                widget.user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: _buildSubtitle(),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_message != null)
                    Text(
                      MyDateUtill.getLastMessageTime(context, _message!.sent),
                      style: TextStyle(
                        fontSize: 12,
                        color: _message!.read.isEmpty && _message!.fromId != widget.currentUID
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: _message!.read.isEmpty && _message!.fromId != widget.currentUID
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Show unread indicator
                  if (_message != null &&
                      _message!.read.isEmpty &&
                      _message!.fromId != widget.currentUID)
                    greenCircle(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    if (_message == null) {
      return Text(
        widget.user.about,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final isMe = _message!.fromId == widget.currentUID;

    if (_message!.type == Type.image) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMe) ...[
            doubleTickIcon(),
            const SizedBox(width: 4),
          ],
          const Icon(
            Icons.image_rounded,
            color: Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'Photo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMe) ...[
          doubleTickIcon(),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            _message!.msg,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: _message!.read.isEmpty && !isMe
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? provider() {
    final image = widget.user.image;
    return image.isEmpty
        ? const NetworkImage(AppConstants.profileImg)
        : NetworkImage(image);
  }

  Widget doubleTickIcon() {
    final isRead = _message?.read.isNotEmpty ?? false;
    return Icon(
      Icons.done_all_rounded,
      color: isRead ? Colors.blue : Colors.grey,
      size: 16,
    );
  }

  Widget greenCircle() {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.green,
      ),
    );
  }
}