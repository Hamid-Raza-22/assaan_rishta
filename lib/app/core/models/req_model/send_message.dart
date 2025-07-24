class SendChat {
  String? senderId;
  String? senderName;
  String? senderProfilePic;
  String? receiverId;
  String? receiverName;
  String? receiverProfilePic;
  String? message;
  String? timestamp;

  SendChat(
      {this.senderId,
      this.senderName,
      this.senderProfilePic,
      this.receiverId,
      this.receiverName,
      this.receiverProfilePic,
      this.message,
      this.timestamp});

  SendChat.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    senderName = json['senderName'];
    senderProfilePic = json['senderProfilePic'];
    receiverId = json['receiverId'];
    receiverName = json['receiverName'];
    receiverProfilePic = json['receiverProfilePic'];
    message = json['message'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['senderName'] = senderName;
    data['senderProfilePic'] = senderProfilePic;
    data['receiverId'] = receiverId;
    data['receiverName'] = receiverName;
    data['receiverProfilePic'] = receiverProfilePic;
    data['message'] = message;
    data['timestamp'] = timestamp;
    return data;
  }
}
