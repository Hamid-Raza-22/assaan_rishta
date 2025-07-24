class AllDegrees {
  List<String>? degreeNames = [];

  AllDegrees({this.degreeNames});

  factory AllDegrees.fromJson(List<dynamic> json) {
    return AllDegrees(
      degreeNames: List<String>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degreeNames': degreeNames,
    };
  }
}
