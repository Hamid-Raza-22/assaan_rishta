class AllCountries {
  int? id;
  String? sortname;
  String? name;
  int? phonecode;

  AllCountries({this.id, this.sortname, this.name, this.phonecode});

  AllCountries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sortname = json['sortname'];
    name = json['name'];
    phonecode = json['phonecode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sortname'] = sortname;
    data['name'] = name;
    data['phonecode'] = phonecode;
    return data;
  }

  // Static method to parse a list of countries from JSON
  static List<AllCountries> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AllCountries.fromJson(json)).toList();
  }

  @override
  String toString() {
    return '$name';
  }
}
