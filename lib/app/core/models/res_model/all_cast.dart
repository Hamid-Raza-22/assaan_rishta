class AllCast {
  List<String>? castNames = [];

  AllCast({this.castNames});

  factory AllCast.fromJson(List<dynamic> json) {
    return AllCast(
      castNames: List<String>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'castNames': castNames,
    };
  }
}
