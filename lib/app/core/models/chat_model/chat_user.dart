class ChatUser {

  late String image;
  late String about;
  late String name;
  late String createdAt;
  late String lastActive;
  late dynamic lastMessage;
  late bool isOnline;
  late bool isInside;
  late bool isMobileOnline;
  late bool isWebOnline;
  late String id;
  late String pushToken;
  late String email;
  late List<String> blockedUsers;

  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.lastActive,
    required this.lastMessage,
    required this.isOnline,
    required this.isInside,
    required this.isMobileOnline,
    required this.isWebOnline,
    required this.id,
    required this.pushToken,
    required this.email,
    this.blockedUsers = const [],
  });

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    lastActive = json['last_active'] ?? '';
    lastMessage = json['last_message'] ?? '';
    isOnline = json['is_online'] ?? false;
    isInside = json['is_inside'] ?? false;
    isMobileOnline = json['is_mobile_online'] ?? false;
    isWebOnline = json['is_web_online'] ?? false;
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
     if (json['blockedUsers'] is Map) {
      blockedUsers = (json['blockedUsers'] as Map<String, dynamic>?)?.keys.toList() ?? [];
    } else {
      blockedUsers = [];
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['last_active'] = lastActive;
    data['last_message'] = lastMessage;
    data['is_online'] = isOnline;
    data['is_inside'] = isInside;
    data['is_mobile_online'] = isMobileOnline;
    data['is_web_online'] = isWebOnline;
    data['id'] = id;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['blockedUsers'] = blockedUsers; // Add blocked users to JSON
    return data;
  }
}
