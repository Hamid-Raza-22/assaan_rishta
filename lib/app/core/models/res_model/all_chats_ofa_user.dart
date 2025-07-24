class AllChatsOFAUser {
  List<Chats>? chats;

  AllChatsOFAUser({this.chats});

  AllChatsOFAUser.fromJson(Map<String, dynamic> json) {
    if (json['chats'] != null) {
      chats = <Chats>[];
      json['chats'].forEach((v) {
        chats!.add(Chats.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chats != null) {
      data['chats'] = chats!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chats {
  String? id;
  String? chatId;
  String? lastMessage;
  String? lastMessageTimestamp;
  List<Participants>? participants;

  Chats(
      {this.id,
      this.chatId,
      this.lastMessage,
      this.lastMessageTimestamp,
      this.participants});

  Chats.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatId = json['chatId'];
    lastMessage = json['lastMessage'];
    lastMessageTimestamp = json['lastMessageTimestamp'];
    if (json['participants'] != null) {
      participants = <Participants>[];
      json['participants'].forEach((v) {
        participants!.add(Participants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['chatId'] = chatId;
    data['lastMessage'] = lastMessage;
    data['lastMessageTimestamp'] = lastMessageTimestamp;
    if (participants != null) {
      data['participants'] = participants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Participants {
  String? senderId;
  String? senderName;
  String? senderProfilePic;
  String? receiverId;
  String? receiverName;
  String? receiverProfilePic;

  Participants(
      {this.senderId,
      this.senderName,
      this.senderProfilePic,
      this.receiverId,
      this.receiverName,
      this.receiverProfilePic});

  Participants.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    senderName = json['senderName'];
    senderProfilePic = json['senderProfilePic'];
    receiverId = json['receiverId'];
    receiverName = json['receiverName'];
    receiverProfilePic = json['receiverProfilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['senderName'] = senderName;
    data['senderProfilePic'] = senderProfilePic;
    data['receiverId'] = receiverId;
    data['receiverName'] = receiverName;
    data['receiverProfilePic'] = receiverProfilePic;
    return data;
  }
}
