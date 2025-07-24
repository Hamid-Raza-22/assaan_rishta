class VendorQuestions {
  int? qusetionID;
  String? qusetion1;
  String? answer;
  int? venderID;

  VendorQuestions(
      {this.qusetionID, this.qusetion1, this.answer, this.venderID});

  VendorQuestions.fromJson(Map<String, dynamic> json) {
    qusetionID = json['Qusetion_ID'];
    qusetion1 = json['Qusetion1'];
    answer = json['Answer'];
    venderID = json['Vender_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Qusetion_ID'] = qusetionID;
    data['Qusetion1'] = qusetion1;
    data['Answer'] = answer;
    data['Vender_ID'] = venderID;
    return data;
  }

  // Static method to parse a list of data from JSON
  static List<VendorQuestions> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => VendorQuestions.fromJson(json)).toList();
  }
}
