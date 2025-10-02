// Fixed message.dart - Remove 'late final' and use proper initialization

import 'package:flutter/material.dart';

class Message {
  String toId;
  String msg;
  String read;
  String fromId;
  String sent;
  Type type;
  bool? isViewOnce;
  bool? isViewed;
  MessageStatus status; // Remove 'late final'
  String? delivered;
  Map<String, String>? reactions;

  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromId,
    required this.sent,
    this.isViewOnce,
    this.isViewed,
    MessageStatus? status, // Make it optional in constructor
    this.delivered,
    this.reactions = const {},
  }) : status = status ?? MessageStatus.pending; // Initialize with default

  Message.fromJson(Map<String, dynamic> json)
      : toId = json['toId'].toString(),
        msg = json['msg'].toString(),
        read = json['read'].toString(),
        fromId = json['fromId'].toString(),
        type = _parseType(json['type']?.toString()), // Initialize type
        sent = json['sent'].toString(),
        delivered = json['delivered']?.toString(),
        status = MessageStatus.pending { // Initialize status before accessing it

    // Parse status - determine based on available data
    if (json['status'] != null) {
      try {
        status = MessageStatus.values.firstWhere(
              (e) => e.name == json['status'],
          orElse: () => MessageStatus.sent,
        );
      } catch (e) {
        status = MessageStatus.sent;
      }
    } else {
      // Determine status based on timestamps
      if (read.isNotEmpty) {
        status = MessageStatus.read;
      } else if (delivered != null && delivered!.isNotEmpty) {
        status = MessageStatus.delivered;
      } else {
        status = MessageStatus.sent;
      }
    }

    isViewOnce = json['isViewOnce'] as bool? ?? false;
    isViewed = json['isViewed'] as bool? ?? false;

    if (json['reactions'] != null) {
      reactions = Map<String, String>.from(json['reactions']);
    } else {
      reactions = {};
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['status'] = status.name;
    data['delivered'] = delivered ?? '';
    data['isViewOnce'] = isViewOnce ?? false;
    data['isViewed'] = isViewed ?? false;
    if (reactions != null && reactions!.isNotEmpty) {
      data['reactions'] = reactions;
    }
    return data;
  }

  // Helper method to update status
  void updateStatus(MessageStatus newStatus) {
    status = newStatus;
    if (newStatus == MessageStatus.delivered) {
      delivered = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Helper method to parse Type from string
  static Type _parseType(String? typeString) {
    if (typeString == Type.viewOnceImage.name) {
      return Type.viewOnceImage;
    } else if (typeString == Type.image.name) {
      return Type.image;
    } else {
      return Type.text; // Default to text if unknown
    }
  }
}

enum Type { text, image, viewOnceImage }

enum MessageStatus {
  pending,   // Message is being sent (clock icon)
  sent,      // Message sent to server (single tick)
  delivered, // Message delivered to recipient (double tick)
  read,      // Message read by recipient (blue double tick)
  failed     // Message failed to send
}

// Simplified status icon builder for message_card.dart
Widget buildMessageStatusIcon(Message message, bool isMe) {
  if (!isMe) return const SizedBox.shrink();

  // For view-once images, show special icon
  if (message.type == Type.viewOnceImage) {
    return Icon(
      message.isViewed == true ? Icons.remove_red_eye : Icons.visibility_off,
      color: message.isViewed == true ? const Color(0xFF4FC3F7) : Colors.white70,
      size: 14,
    );
  }

  // Regular message status
  switch (message.status) {
    case MessageStatus.pending:
      return const Icon(Icons.access_time, color: Colors.white60, size: 14);

    case MessageStatus.sent:
      return const Icon(Icons.done, color: Colors.white70, size: 14);

    case MessageStatus.delivered:
      return const Icon(Icons.done_all, color: Colors.white70, size: 14);

    case MessageStatus.read:
      return const Icon(Icons.done_all, color: Color(0xFF4FC3F7), size: 14);

    case MessageStatus.failed:
      return const Icon(Icons.error_outline, color: Colors.red, size: 14);

    }
}