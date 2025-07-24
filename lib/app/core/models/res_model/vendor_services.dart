class VendorServices {
  int? servicesID;
  String? servicesName;
  String? servicesDiscription;
  String? servicesCatID;
  int? venderID;

  VendorServices({
    this.servicesID,
    this.servicesName,
    this.servicesDiscription,
    this.servicesCatID,
    this.venderID,
  });

  VendorServices.fromJson(Map<String, dynamic> json) {
    servicesID = json['Services_ID'];
    servicesName = json['Services_name'];
    servicesDiscription = json['Services_discription'];
    servicesCatID = json['Services_cat_ID'];
    venderID = json['Vender_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Services_ID'] = servicesID;
    data['Services_name'] = servicesName;
    data['Services_discription'] = servicesDiscription;
    data['Services_cat_ID'] = servicesCatID;
    data['Vender_ID'] = venderID;
    return data;
  }

  // Static method to parse a list of data from JSON
  static List<VendorServices> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => VendorServices.fromJson(json)).toList();
  }
}
