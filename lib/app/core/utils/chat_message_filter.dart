import '../models/chat_model/message.dart';

class ChatMessageFilter {
  static List<Message> afterDeletion(
      List<Message> messages, String? deletionTime) {
    if (deletionTime == null) return messages;
    final boundary = int.tryParse(deletionTime);
    if (boundary == null) return messages;
    return messages.where((message) {
      final sent = int.tryParse(message.sent);
      return sent != null && sent > boundary;
    }).toList();
  }
}
