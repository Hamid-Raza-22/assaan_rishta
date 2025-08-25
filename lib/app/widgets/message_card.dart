import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:chatview/chatview.dart' as chatview;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
import '../viewmodels/chat_viewmodel.dart';

class ProfessionalMessageCard extends StatefulWidget {
  final Message message;
  final bool pause;
  final String? currentUserId;
  final Function(Message)? onMessageLongPress;
  final Function(Message)? onMessageTap;
  final bool showMessageTime;
  final bool showUserAvatar;
  final String? userAvatarUrl;
  final Function(Message, String)? onReaction;
  final Function(Message)? onReply;

  const ProfessionalMessageCard({
    super.key,
    required this.message,
    required this.pause,
    this.currentUserId,
    this.onMessageLongPress,
    this.onMessageTap,
    this.showMessageTime = true,
    this.showUserAvatar = false,
    this.userAvatarUrl,
    this.onReaction,
    this.onReply,
  });

  @override
  State<ProfessionalMessageCard> createState() => _ProfessionalMessageCardState();
}

class _ProfessionalMessageCardState extends State<ProfessionalMessageCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final useCase = Get.find<UserManagementUseCase>();
  final chatController = Get.find<ChatViewModel>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatMq = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final currentUserId = widget.currentUserId ?? useCase.getUserId().toString();
    final isMe = currentUserId == widget.message.fromId;

    // Mark message as read if conditions are met
    if (widget.message.read.isEmpty && !widget.pause && !isMe) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatController.markMessageAsRead(widget.message);
      });
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildMessageContainer(context, chatMq, theme, isMe),
        );
      },
    );
  }

  Widget _buildMessageContainer(BuildContext context, Size chatMq, ThemeData theme, bool isMe) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: chatMq.width * 0.02,
        vertical: chatMq.height * 0.005,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User avatar for received messages
          if (!isMe && widget.showUserAvatar) ...[
            _buildUserAvatar(),
            const SizedBox(width: 8),
          ],

          // Message bubble
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: chatMq.width * 0.75,
                minWidth: chatMq.width * 0.1,
              ),
              child: GestureDetector(
                onTap: () {
                  widget.onMessageTap?.call(widget.message);
                  HapticFeedback.selectionClick();
                },
                onLongPress: () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onMessageLongPress?.call(widget.message) ??
                      _showMessageActions(context, widget.message, isMe);
                  HapticFeedback.mediumImpact();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? LinearGradient(
                      colors: [
                        AppColors.secondaryColor,
                        AppColors.secondaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : LinearGradient(
                      colors: [
                        const Color(0xFFF8F9FA),
                        const Color(0xFFE9ECEF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: _getBorderRadius(isMe),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMessageContent(context, chatMq, isMe),
                ),
              ),
            ),
          ),

          // User avatar for sent messages
          if (isMe && widget.showUserAvatar) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  BorderRadius _getBorderRadius(bool isMe) {
    return BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.secondaryColor.withOpacity(0.1),
      backgroundImage: widget.userAvatarUrl != null
          ? CachedNetworkImageProvider(widget.userAvatarUrl!)
          : null,
      child: widget.userAvatarUrl == null
          ? Icon(
        Icons.person,
        size: 18,
        color: AppColors.secondaryColor,
      )
          : null,
    );
  }

  Widget _buildMessageContent(BuildContext context, Size chatMq, bool isMe) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: chatMq.height * 0.012,
        horizontal: widget.message.type == Type.image
            ? chatMq.width * 0.02
            : chatMq.width * 0.04,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message content
          _buildMessageBody(context, isMe),

          // Message metadata
          if (widget.showMessageTime) ...[
            const SizedBox(height: 6),
            _buildMessageMetadata(context, isMe),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBody(BuildContext context, bool isMe) {
    switch (widget.message.type) {
      case Type.text:
        return _buildTextMessage(context, isMe);
      case Type.image:
        return _buildImageMessage(context);
      default:
        return _buildTextMessage(context, isMe);
    }
  }

  Widget _buildTextMessage(BuildContext context, bool isMe) {
    return SelectableText(
      widget.message.msg,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: isMe ? Colors.white : const Color(0xFF2D3748),
        height: 1.4,
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return ClipRRectWithShadow(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.message.msg,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageMetadata(BuildContext context, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          MyDateUtill.getFormatedTime(
            context: context,
            time: widget.message.sent,
          ),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: isMe ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            widget.message.read.isNotEmpty
                ? Icons.done_all_rounded
                : Icons.done_rounded,
            color: widget.message.read.isNotEmpty
                ? const Color(0xFF4FC3F7)
                : Colors.white70,
            size: 14,
          ),
        ],
      ],
    );
  }

  void _showMessageActions(BuildContext context, Message message, bool isMe) {
    final chatMq = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Action items
            ..._buildActionItems(context, message, isMe),

            // Bottom spacing
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionItems(BuildContext context, Message message, bool isMe) {
    final actions = <Widget>[];

    // Copy/Save action
    if (message.type == Type.text) {
      actions.add(_buildActionItem(
        icon: Icons.content_copy_rounded,
        title: 'Copy Message',
        onTap: () => _copyMessage(context, message),
      ));
    } else if (message.type == Type.image) {
      actions.add(_buildActionItem(
        icon: Icons.download_rounded,
        title: 'Save Image',
        onTap: () => _saveImage(context, message),
      ));
    }

    if (isMe) {
      // Edit action (text only)
      if (message.type == Type.text) {
        actions.add(_buildActionItem(
          icon: Icons.edit_rounded,
          title: 'Edit Message',
          onTap: () => _editMessage(context, message),
        ));
      }

      // Delete action
      actions.add(_buildActionItem(
        icon: Icons.delete_rounded,
        title: 'Delete Message',
        color: Colors.red,
        onTap: () => _deleteMessage(context, message),
      ));
    }

    // Message info
    actions.add(_buildDivider());

    // Reply action
    actions.add(_buildActionItem(
      icon: Icons.reply_rounded,
      title: 'Reply',
      onTap: () {
        Navigator.pop(context);
        widget.onReply?.call(message);
      },
    ));

    // Reactions
    actions.add(_buildReactionsRow(context, message));

    actions.add(_buildActionItem(
      icon: Icons.info_outline_rounded,
      title: 'Message Info',
      onTap: () => _showMessageInfo(context, message),
    ));

    return actions;
  }

  Widget _buildReactionsRow(BuildContext context, Message message) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: reactions
            .map((reaction) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onReaction?.call(message, reaction);
                    // Optionally show a confirmation
                    AppUtils.successData(title: "Reacted", message: "You reacted with $reaction");
                  },
                  child: Text(
                    reaction,
                    style: const TextStyle(fontSize: 24),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blue),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: color ?? Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade300,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
    );
  }

  Future<void> _copyMessage(BuildContext context, Message message) async {
    await Clipboard.setData(ClipboardData(text: message.msg));
    Navigator.pop(context);
    AppUtils.successData(
      title: "Copied",
      message: 'Message copied to clipboard',
    );
  }

  Future<void> _saveImage(BuildContext context, Message message) async {
    try {
      Navigator.pop(context);
      final tempDir = Directory.systemTemp.path;
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$tempDir/$fileName';

      await Dio().download(message.msg, filePath);
      await Gal.putImage(filePath);

      AppUtils.successData(
        title: "Saved",
        message: 'Image saved to gallery',
      );
    } catch (e) {
      AppUtils.failedData(
        title: "Error",
        message: 'Failed to save image',
      );
    }
  }

  Future<void> _editMessage(BuildContext context, Message message) async {
    Navigator.pop(context);
    await _showEditDialog(context, message);
  }

  Future<void> _deleteMessage(BuildContext context, Message message) async {
    Navigator.pop(context);
    await chatController.deleteMessage(message);
    AppUtils.successData(
      title: "Deleted",
      message: 'Message deleted',
    );
  }

  void _showMessageInfo(BuildContext context, Message message) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Message Info',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Sent:', MyDateUtill.getMessageTime(
              context: context,
              time: message.sent,
            )),
            const SizedBox(height: 8),
            _buildInfoRow('Read:', message.read.isEmpty
                ? 'Not seen yet'
                : MyDateUtill.getMessageTime(
              context: context,
              time: message.read,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context, Message message) async {
    String updatedMsg = message.msg;
    final controller = TextEditingController(text: message.msg);

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Edit Message',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: null,
          style: GoogleFonts.inter(),
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (updatedMsg.trim().isNotEmpty && updatedMsg != message.msg) {
                await chatController.updateMessage(message, updatedMsg);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Update',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for image with shadow
class ClipRRectWithShadow extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRRectWithShadow({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}