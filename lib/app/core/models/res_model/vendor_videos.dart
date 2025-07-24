class VendorVideos {
  int? videoID;
  String? videoName;
  dynamic videoSize;
  dynamic videoExtention;
  int? venderID;
  dynamic videoTime;
  dynamic videoCreatedDate;

  VendorVideos({
    this.videoID,
    this.videoName,
    this.videoSize,
    this.videoExtention,
    this.venderID,
    this.videoTime,
    this.videoCreatedDate
  });

  VendorVideos.fromJson(Map<String, dynamic> json) {
    videoID = json['Video_ID'];
    videoName = json['Video_name'];
    videoSize = json['Video_size'];
    videoExtention = json['Video_extention'];
    venderID = json['Vender_ID'];
    videoTime = json['Video_time'];
    videoCreatedDate = json['Video_created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Video_ID'] = videoID;
    data['Video_name'] = videoName;
    data['Video_size'] = videoSize;
    data['Video_extention'] = videoExtention;
    data['Vender_ID'] = venderID;
    data['Video_time'] = videoTime;
    data['Video_created_date'] = videoCreatedDate;
    return data;
  }

  // Static method to parse a list of data from JSON
  static List<VendorVideos> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => VendorVideos.fromJson(json)).toList();
  }
}
