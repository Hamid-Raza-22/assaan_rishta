class AllStates {
  int? id;
  String? name;
  int? countryId;

  AllStates({this.id, this.name, this.countryId});

  AllStates.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    countryId = json['country_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['country_id'] = countryId;
    return data;
  }

  // Static method to parse a list of countries from JSON
  static List<AllStates> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AllStates.fromJson(json)).toList();
  }

  @override
  String toString() {
    return '$name';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllStates &&
          runtimeType == other.runtimeType &&
          ((id != null && other.id != null)
              ? id == other.id
              : name?.toLowerCase() == other.name?.toLowerCase());

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
