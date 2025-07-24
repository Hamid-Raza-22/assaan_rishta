class AllCities {
  int? id;
  String? name;
  int? stateId;

  AllCities({this.id, this.name, this.stateId});

  AllCities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    stateId = json['state_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['state_id'] = stateId;
    return data;
  }

  // Static method to parse a list of countries from JSON
  static List<AllCities> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AllCities.fromJson(json)).toList();
  }

  @override
  String toString() {
    return '$name';
  }
}
