class VendorAlbums {
  int? imagesID;
  String? imagesName;
  int? venderID;

  VendorAlbums({this.imagesID, this.imagesName, this.venderID});

  VendorAlbums.fromJson(Map<String, dynamic> json) {
    imagesID = json['images_ID'];
    imagesName = json['images_name'];
    venderID = json['Vender_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['images_ID'] = imagesID;
    data['images_name'] = imagesName;
    data['Vender_ID'] = venderID;
    return data;
  }

  // Static method to parse a list of data from JSON
  static List<VendorAlbums> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => VendorAlbums.fromJson(json)).toList();
  }
}
