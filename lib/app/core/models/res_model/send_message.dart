class SendMessage {
  String? status;
  String? message;
  String? chatId;

  SendMessage({this.status, this.message, this.chatId});

  SendMessage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    chatId = json['chatId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['chatId'] = chatId;
    return data;
  }
}
