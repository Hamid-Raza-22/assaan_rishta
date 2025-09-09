import 'dart:io';
import 'package:assaan_rishta/app/widgets/view_once_image_viewer.dart';
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
  State<ProfessionalMessageCard> createState() =>
      _ProfessionalMessageCardState();
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatMq = MediaQuery
        .of(context)
        .size;
    final theme = Theme.of(context);
    final currentUserId =
        widget.currentUserId ?? useCase.getUserId().toString();
    final isMe = currentUserId == widget.message.fromId;

    // Mark regular message as read if conditions are met
    if (widget.message.read.isEmpty &&
        !widget.pause &&
        !isMe &&
        widget.message.type != Type.viewOnceImage) {
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

  Widget _buildMessageContainer(BuildContext context,
      Size chatMq,
      ThemeData theme,
      bool isMe,) {
    final isViewedOnce =
        widget.message.isViewOnce == true && widget.message.isViewed == true;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: chatMq.width * 0.02,
        vertical: chatMq.height * 0.005,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && widget.showUserAvatar) ...[
            _buildUserAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: chatMq.width * 0.75,
                minWidth: chatMq.width * 0.1,
              ),
              child: Stack(
                clipBehavior: Clip.none, // Allow reactions to overflow
                children: [
                  // Main message bubble
                  GestureDetector(
                    onTap: () {
                      if (widget.message.type == Type.viewOnceImage &&
                          widget.message.isViewed != true &&
                          !isMe) {
                        _openViewOnceImage(context);
                      } else {
                        widget.onMessageTap?.call(widget.message);
                      }
                      HapticFeedback.selectionClick();
                    },
                    onLongPress: () {
                      if (widget.message.type != Type.viewOnceImage) {
                        _animationController.forward().then((_) {
                          _animationController.reverse();
                        });
                        // Show overlay reactions on long press
                        _showQuickReactions(context, widget.message, isMe);
                        HapticFeedback.mediumImpact();
                      }
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
                      child: _buildMessageContentWithoutReactions(
                          context, chatMq, isMe),
                    ),
                  ),

                  // Reactions positioned outside the bubble
                  if (widget.message.reactions != null &&
                      widget.message.reactions!.isNotEmpty)
                    Positioned(
                      bottom: -20,
                      right: isMe ? 10 : null,
                      left: !isMe ? 10 : null,
                      child: _buildReactionBubble(context, isMe),
                    ),
                ],
              ),
            ),
          ),
          if (isMe && widget.showUserAvatar) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  // Quick reactions overlay (WhatsApp-style)
  void _showQuickReactions(BuildContext context, Message message, bool isMe) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Message options on top bar
            Positioned(
              top: MediaQuery
                  .of(context)
                  .padding
                  .top + 4,
              left: 20,
              right: 20,
              child: _buildTopBarOptions(context, message, isMe),
            ),

            // Quick reactions above the message
            Positioned(
              top: position.dy - 100,
              left: isMe ? null : position.dx,
              right: isMe ? MediaQuery
                  .of(context)
                  .size
                  .width - position.dx - size.width : null,
              child: _buildQuickReactionBar(context, message),
            ),

            // Highlighted message
            Positioned(
              top: position.dy-38,
              left: position.dx,
              width: size.width,
              height: size.height,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.25),
                  borderRadius: _getBorderRadius(isMe),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  } // Top bar with message options (WhatsApp-style)
  // Quick reaction bar (appears above message)
  Widget _buildQuickReactionBar(BuildContext context, Message message) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    final chatController = Get.find<ChatViewModel>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((reaction) {
          final currentUserId = useCase.getUserId().toString();
          final hasReacted = message.reactions?[currentUserId] == reaction;

          return GestureDetector(
            onTap: () async {
              Navigator.pop(context);

              if (hasReacted) {
                await chatController.removeMessageReaction(message);
              } else {
                await chatController.addMessageReaction(message, reaction);
              }

              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasReacted ? Colors.blue.withOpacity(0.1) : Colors
                    .transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                reaction,
                style: TextStyle(
                  fontSize: hasReacted ? 28 : 24,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

// Updated edit dialog with better UI
  Future<void> _showEditDialog(BuildContext context, Message message) async {
    String updatedMsg = message.msg;
    final controller = TextEditingController(text: message.msg);

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Message',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 15),
                onChanged: (value) => updatedMsg = value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type your message...',
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  if (updatedMsg
                      .trim()
                      .isNotEmpty && updatedMsg != message.msg) {
                    await chatController.updateMessage(message, updatedMsg);
                    HapticFeedback.lightImpact();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Update',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
    );
  }
// Delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Message message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Message?'),
        content: const Text('This message will be deleted for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
               Get.back();
              await chatController.deleteMessage(message);
               Navigator.pop(context);
              AppUtils.successData(
                title: "Deleted",
                message: 'Message deleted successfully',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  Widget _buildTopBarOptions(BuildContext context, Message message, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reply
          _buildTopBarIcon(
            Icons.reply,
                () {
              Navigator.pop(context);
              widget.onReply?.call(message);
            },
          ),

          // Copy (for text messages)
          if (message.type == Type.text)
            _buildTopBarIcon(
              Icons.content_copy,
                  () => _copyMessage(context, message),
            ),

          // Save (for images)
          if (message.type == Type.image)
            _buildTopBarIcon(
              Icons.download,
                  () => _saveImage(context, message),
            ),

          // Edit (for own text messages)
          if (isMe && message.type == Type.text)
            _buildTopBarIcon(
              Icons.edit,
                  () {
                Navigator.pop(context);
                _showEditDialog(context, message);
              },
            ),

          // Delete (for own messages)
          if (isMe)
            _buildTopBarIcon(
              Icons.delete,
                  () {
                    // Navigator.pop(context);
                    _showDeleteConfirmation(context, message);
              },
              color: Colors.red,
            ),

          // Info
          _buildTopBarIcon(
            Icons.info_outline,
                () {
              // Navigator.pop(context);
              _showMessageInfo(context, message);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 24,
          color: color ?? Colors.grey[700],
        ),
      ),
    );
  }

  // Enhanced reaction bubble that appears outside message
  Widget _buildReactionBubble(BuildContext context, bool isMe) {
    final reactions = widget.message.reactions!;

    // Group reactions by emoji
    final Map<String, List<String>> groupedReactions = {};
    reactions.forEach((userId, reaction) {
      if (groupedReactions.containsKey(reaction)) {
        groupedReactions[reaction]!.add(userId);
      } else {
        groupedReactions[reaction] = [userId];
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: groupedReactions.entries.map((entry) {
          final reaction = entry.key;
          final count = entry.value.length;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reaction,
                  style: const TextStyle(fontSize: 14),
                ),
                if (count > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Add this method to your ProfessionalMessageCard class in message_card.dart
// New method for message content without reactions
  Widget _buildMessageContentWithoutReactions(BuildContext context, Size chatMq,
      bool isMe) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: chatMq.height * 0.012,
        horizontal: chatMq.width * 0.04,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMessageBody(context, isMe),
          if (widget.showMessageTime) ...[
            const SizedBox(height: 6),
            _buildMessageMetadata(context, isMe),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Size chatMq, bool isMe) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: chatMq.height * 0.012,
        horizontal: chatMq.width * 0.04,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMessageBody(context, isMe),

          // Add reactions display here
          if (widget.message.reactions != null &&
              widget.message.reactions!.isNotEmpty)
            _buildReactionsDisplay(context, isMe),

          if (widget.showMessageTime) ...[
            const SizedBox(height: 6),
            _buildMessageMetadata(context, isMe),
          ],
        ],
      ),
    );
  }

// Add this new method to display reactions
  Widget _buildReactionsDisplay(BuildContext context, bool isMe) {
    final reactions = widget.message.reactions!;

    // Group reactions by emoji
    final Map<String, List<String>> groupedReactions = {};
    reactions.forEach((userId, reaction) {
      if (groupedReactions.containsKey(reaction)) {
        groupedReactions[reaction]!.add(userId);
      } else {
        groupedReactions[reaction] = [userId];
      }
    });

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: groupedReactions.entries.map((entry) {
          final reaction = entry.key;
          final userIds = entry.value;
          final count = userIds.length;

          return GestureDetector(
            onTap: () => _showReactionUsers(context, reaction, userIds),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reaction,
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (count > 1) ...[
                    const SizedBox(width: 2),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

// Show who reacted with what
  void _showReactionUsers(BuildContext context, String reaction,
      List<String> userIds) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Row(
              children: [
                Text(reaction),
                const SizedBox(width: 8),
                Text(
                  'Reactions',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: userIds.map((userId) {
                // You can fetch user names here or show user IDs for now
                final currentUserId = useCase.getUserId().toString();
                final userName = userId == currentUserId
                    ? 'You'
                    : 'User $userId';

                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.secondaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  title: Text(userName),
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
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

  BorderRadius _getBorderRadius(bool isMe) {
    return BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
    );
  }

  Widget _buildMessageBody(BuildContext context, bool isMe) {
    // Handle view-once images
    if (widget.message.type == Type.viewOnceImage) {
      return _buildViewOnceMessage(context, isMe);
    }

    // Handle viewed view-once message
    if (widget.message.isViewOnce == true && widget.message.isViewed == true) {
      return _buildViewedOnceMessage(context, isMe);
    }

    switch (widget.message.type) {
      case Type.text:
        return _buildTextMessage(context, isMe);
      case Type.image:
        return _buildImageMessage(context);
      case Type.viewOnceImage:
        return _buildViewOnceMessage(context, isMe);
      default:
        return _buildTextMessage(context, isMe);
    }
  }

  Widget _buildViewOnceMessage(BuildContext context, bool isMe) {
    final currentUserId = useCase.getUserId().toString();
    final canView = !isMe && widget.message.isViewed != true;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canView
            ? Colors.orange.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canView
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            canView ? Icons.photo_camera : Icons.check_circle,
            color: canView ? Colors.orange : Colors.grey,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            canView
                ? '📸 Tap to view photo'
                : (isMe ? 'Photo sent' : 'Photo was viewed'),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isMe ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (canView) ...[
            const SizedBox(height: 4),
            Text(
              'Photo will disappear after viewing',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewedOnceMessage(BuildContext context, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          color: isMe ? Colors.white70 : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'Photo was viewed',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: isMe ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return ClipRRectWithShadow(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.message.msg,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        errorWidget: (context, url, error) =>
            Container(
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

  void _openViewOnceImage(BuildContext context) {
    // Check if already viewed
    if (widget.message.isViewed == true) {
      Get.snackbar(
        'Already Viewed',
        'This photo has already been viewed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final currentUserId = useCase.getUserId().toString();

    // Only allow receiver to view
    if (widget.message.fromId == currentUserId) {
      Get.snackbar(
        'Info',
        'You sent this view-once photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewOnceImageViewer(
              message: widget.message,
              onViewed: () async {
                // Mark as viewed and delete image
                await chatController.markViewOnceAsViewed(widget.message);
              },
            ),
      ),
    );
  }

// 5. Updated Message Metadata in ProfessionalMessageCard
// message_card.dart - Update the _buildMessageMetadata method

  Widget _buildMessageMetadata(BuildContext context, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Time
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

        // Status icon for sent messages
        if (isMe) ...[
          const SizedBox(width: 4),
          buildMessageStatusIcon(widget.message, isMe),
        ],
      ],
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
          ? Icon(Icons.person, size: 18, color: AppColors.secondaryColor)
          : null,
    );
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


  void _showMessageActions(BuildContext context, Message message, bool isMe) {
    final chatMq = MediaQuery
        .of(context)
        .size;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          Container(
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
                SizedBox(height: MediaQuery
                    .of(context)
                    .padding
                    .bottom + 20),
              ],
            ),
          ),
    );
  }

  List<Widget> _buildActionItems(BuildContext context,
      Message message,
      bool isMe,) {
    final actions = <Widget>[];

    // Copy/Save action
    if (message.type == Type.text) {
      actions.add(
        _buildActionItem(
          icon: Icons.content_copy_rounded,
          title: 'Copy Message',
          onTap: () => _copyMessage(context, message),
        ),
      );
    } else if (message.type == Type.image) {
      actions.add(
        _buildActionItem(
          icon: Icons.download_rounded,
          title: 'Save Image',
          onTap: () => _saveImage(context, message),
        ),
      );
    }

    if (isMe) {
      // Edit action (text only)
      if (message.type == Type.text) {
        actions.add(
          _buildActionItem(
            icon: Icons.edit_rounded,
            title: 'Edit Message',
            onTap: () => _editMessage(context, message),
          ),
        );
      }

      // Delete action
      actions.add(
        _buildActionItem(
          icon: Icons.delete_rounded,
          title: 'Delete Message',
          color: Colors.red,
          onTap: () => _deleteMessage(context, message),
        ),
      );
    }

    // Message info
    actions.add(_buildDivider());

    // Reply action
    actions.add(
      _buildActionItem(
        icon: Icons.reply_rounded,
        title: 'Reply',
        onTap: () {
          Navigator.pop(context);
          widget.onReply?.call(message);
        },
      ),
    );

    // Reactions
    actions.add(_buildReactionsRow(context, message));

    actions.add(
      _buildActionItem(
        icon: Icons.info_outline_rounded,
        title: 'Message Info',
        onTap: () => _showMessageInfo(context, message),
      ),
    );

    return actions;
  }

// Update the _buildReactionsRow method in your ProfessionalMessageCard class

  Widget _buildReactionsRow(BuildContext context, Message message) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    final chatController = Get.find<ChatViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: reactions
            .map((reaction) =>
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);

                try {
                  // Check if user already reacted with this emoji
                  final currentUserId = useCase.getUserId().toString();
                  final userReaction = message.reactions?[currentUserId];

                  if (userReaction == reaction) {
                    // Remove reaction if same emoji is clicked
                    await chatController.removeMessageReaction(message);
                    AppUtils.successData(
                        title: "Reaction Removed",
                        message: "You removed your reaction"
                    );
                  } else {
                    // Add new reaction
                    await chatController.addMessageReaction(message, reaction);
                    AppUtils.successData(
                        title: "Reaction Added",
                        message: "You reacted with $reaction"
                    );
                  }
                } catch (e) {
                  AppUtils.failedData(
                      title: "Error",
                      message: "Failed to add reaction"
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reaction,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ))
            .toList(),
      ),
    );
  }

  // 4. Update Message Status Widget in message_card.dart
// This widget displays the appropriate status icon

  Widget _buildMessageStatus(MessageStatus status, bool isMe) {
    if (!isMe) return const SizedBox.shrink();

    IconData icon;
    Color color;
    double size = 14;

    switch (status) {
      case MessageStatus.pending:
      // Clock icon for pending
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
      // Single tick
        icon = Icons.done;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
      // Double tick
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
      // Blue double tick
        icon = Icons.done_all;
        color = const Color(0xFF4FC3F7);
        break;
      case MessageStatus.failed:
      // Error icon
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(icon, color: color, size: size);
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
        style: GoogleFonts.inter(fontSize: 16, color: color ?? Colors.black87),
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
      final fileName = 'image_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final filePath = '$tempDir/$fileName';

      await Dio().download(message.msg, filePath);
      await Gal.putImage(filePath);

      AppUtils.successData(title: "Saved", message: 'Image saved to gallery');
    } catch (e) {
      AppUtils.failedData(title: "Error", message: 'Failed to save image');
    }
  }

  Future<void> _editMessage(BuildContext context, Message message) async {
    Navigator.pop(context);
    await _showEditDialog(context, message);
  }

  Future<void> _deleteMessage(BuildContext context, Message message) async {
    Navigator.pop(context);
    await chatController.deleteMessage(message);
    AppUtils.successData(title: "Deleted", message: 'Message deleted');
  }

  void _showMessageInfo(BuildContext context, Message message) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(
              'Message Info',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Sent:',
                  MyDateUtill.getMessageTime(
                      context: context, time: message.sent),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Read:',
                  message.read.isEmpty
                      ? 'Not seen yet'
                      : MyDateUtill.getMessageTime(
                    context: context,
                    time: message.read,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>{
                Get.back()},
                child: Text(
                    'Close', style: GoogleFonts.inter(color: Colors.blue)),
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
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 14))),
      ],
    );
  }

//   Future<void> _showEditDialog(BuildContext context, Message message) async {
//     String updatedMsg = message.msg;
//     final controller = TextEditingController(text: message.msg);
//
//     return showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.edit, color: Colors.blue),
//             const SizedBox(width: 8),
//             Text(
//               'Edit Message',
//               style: GoogleFonts.inter(fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//         content: TextField(
//           controller: controller,
//           maxLines: null,
//           style: GoogleFonts.inter(),
//           onChanged: (value) => updatedMsg = value,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.blue),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(dialogContext);
//               if (updatedMsg.trim().isNotEmpty && updatedMsg != message.msg) {
//                 await chatController.updateMessage(message, updatedMsg);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'Update',
//               style: GoogleFonts.inter(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Custom widget for image with shadow
}
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
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}
