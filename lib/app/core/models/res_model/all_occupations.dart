class AllOccupations {
  List<String>? occupationNames = [];

  AllOccupations({this.occupationNames});

  factory AllOccupations.fromJson(List<dynamic> json) {
    return AllOccupations(
      occupationNames: List<String>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'occupationNames': occupationNames,
    };
  }
}
