// message.dart - Complete Message model with status support

enum MessageStatus {
  sending,    // Clock icon - message is being sent
  sent,       // Single gray tick - message sent to server
  delivered,  // Double gray tick - message delivered to recipient
  read        // Double blue tick - message read by recipient
}

enum Type { text, image }

class Message {
  late final String toId;
  late final String msg;
  late final String read;
  late final String fromId;
  late final String sent;
  late final Type type;
  late MessageStatus status; // Made mutable for updates
  late final String? delivered; // Optional delivered timestamp

  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromId,
    required this.sent,
    this.status = MessageStatus.sending,
    this.delivered,
  });

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'] ?? '';
    msg = json['msg'] ?? '';
    read = json['read'] ?? '';
    type = json['type'] == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'] ?? '';
    sent = json['sent'] ?? '';
    delivered = json['delivered']?.toString();

    // Determine status based on fields
    status = _determineStatus(json);
  }

  // Helper method to determine status from JSON
  MessageStatus _determineStatus(Map<String, dynamic> json) {
    // Priority: read > delivered > sent > sending

    // Check if message is read
    if (json['read'] != null && json['read'].toString().isNotEmpty) {
      return MessageStatus.read;
    }

    // Check if message is delivered
    if (json['delivered'] != null && json['delivered'].toString().isNotEmpty) {
      return MessageStatus.delivered;
    }

    // Check explicit status field
    if (json['status'] != null) {
      switch (json['status']) {
        case 'read':
          return MessageStatus.read;
        case 'delivered':
          return MessageStatus.delivered;
        case 'sent':
          return MessageStatus.sent;
        case 'failed':
        case 'sending':
          return MessageStatus.sending;
      }
    }

    // If sent timestamp exists, consider it sent
    if (json['sent'] != null && json['sent'].toString().isNotEmpty) {
      return MessageStatus.sent;
    }

    // Default to sending
    return MessageStatus.sending;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['status'] = statusToString(status);
    data['delivered'] = delivered ?? '';
    return data;
  }

  // Convert status enum to string for storage
  String statusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
    }
  }

  // Create status from string
  static MessageStatus statusFromString(String? status) {
    switch (status) {
      case 'read':
        return MessageStatus.read;
      case 'delivered':
        return MessageStatus.delivered;
      case 'sent':
        return MessageStatus.sent;
      case 'sending':
      default:
        return MessageStatus.sending;
    }
  }

  // Helper getters
  bool get isSending => status == MessageStatus.sending;
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isRead => status == MessageStatus.read;

  // Check if message is from current user (for showing status)
  bool isFromUser(String userId) => fromId == userId;

  // Copy with method for updating message
  Message copyWith({
    String? toId,
    String? msg,
    String? read,
    Type? type,
    String? fromId,
    String? sent,
    MessageStatus? status,
    String? delivered,
  }) {
    return Message(
      toId: toId ?? this.toId,
      msg: msg ?? this.msg,
      read: read ?? this.read,
      type: type ?? this.type,
      fromId: fromId ?? this.fromId,
      sent: sent ?? this.sent,
      status: status ?? this.status,
      delivered: delivered ?? this.delivered,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.sent == sent &&
        other.fromId == fromId &&
        other.toId == toId;
  }

  @override
  int get hashCode => sent.hashCode ^ fromId.hashCode ^ toId.hashCode;
}