class AllMessagesOFaChat {
  List<Messages>? messages;

  AllMessagesOFaChat({this.messages});

  AllMessagesOFaChat.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? id;
  String? senderId;
  String? senderName;
  String? message;
  bool? seen;
  String? senderProfilePic;
  String? timestamp;

  Messages(
      {this.id,
      this.senderId,
      this.senderName,
      this.message,
      this.seen,
      this.senderProfilePic,
      this.timestamp});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    senderName = json['senderName'];
    message = json['message'];
    seen = json['seen'];
    senderProfilePic = json['senderProfilePic'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['senderId'] = senderId;
    data['senderName'] = senderName;
    data['message'] = message;
    data['seen'] = seen;
    data['senderProfilePic'] = senderProfilePic;
    data['timestamp'] = timestamp;
    return data;
  }
}
