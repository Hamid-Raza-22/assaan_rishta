class ConnectsHistory {
  int? id;
  int? userId;
  int? userforId;
  String? username;
  String? userForName;
  int? connects;
  int? remainingConnects;
  String? connectionDescription;
  DateTime? date;

  ConnectsHistory({
    this.id,
    this.userId,
    this.userforId,
    this.username,
    this.userForName,
    this.connects,
    this.remainingConnects,
    this.connectionDescription,
    this.date,
  });

  ConnectsHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    userforId = json['userforId'];
    username = json['Username'];
    userForName = json['userForName'];
    connects = json['connects'];
    remainingConnects = json['remainingConnects'];
    connectionDescription = json['connectionDescription'];
    date = json['date'] != null
        ? DateTime.parse(json['date'])
        : DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['userforId'] = userforId;
    data['Username'] = username;
    data['userForName'] = userForName;
    data['connects'] = connects;
    data['remainingConnects'] = remainingConnects;
    data['connectionDescription'] = connectionDescription;
    data['date'] = date?.toIso8601String();
    return data;
  }

  // Static method to parse a list from JSON
  static List<ConnectsHistory> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ConnectsHistory.fromJson(json)).toList();
  }
}