class VendorPackages {
  int? packageID;
  String? packageName;
  double? packageMinPrice;
  double? packageMaxPrice;
  String? packagePriceType;
  String? packageStatus;
  String? packageTaxPrice;
  String? packageDiscription;
  String? packageCallforprice;
  int? venderID;
  String? packageCreatedDate;
  String? packageModifyDate;

  VendorPackages({
    this.packageID,
    this.packageName,
    this.packageMinPrice,
    this.packageMaxPrice,
    this.packagePriceType,
    this.packageStatus,
    this.packageTaxPrice,
    this.packageDiscription,
    this.packageCallforprice,
    this.venderID,
    this.packageCreatedDate,
    this.packageModifyDate,
  });

  VendorPackages.fromJson(Map<String, dynamic> json) {
    packageID = json['Package_ID'];
    packageName = json['Package_name'];
    packageMinPrice = json['Package_min_price'];
    packageMaxPrice = json['Package_max_price'];
    packagePriceType = json['Package_price_type'];
    packageStatus = json['Package_status'];
    packageTaxPrice = json['Package_tax_price'];
    packageDiscription = json['Package_discription'];
    packageCallforprice = json['Package_callforprice'];
    venderID = json['Vender_ID'];
    packageCreatedDate = json['Package_created_date'];
    packageModifyDate = json['Package_modify_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Package_ID'] = packageID;
    data['Package_name'] = packageName;
    data['Package_min_price'] = packageMinPrice;
    data['Package_max_price'] = packageMaxPrice;
    data['Package_price_type'] = packagePriceType;
    data['Package_status'] = packageStatus;
    data['Package_tax_price'] = packageTaxPrice;
    data['Package_discription'] = packageDiscription;
    data['Package_callforprice'] = packageCallforprice;
    data['Vender_ID'] = venderID;
    data['Package_created_date'] = packageCreatedDate;
    data['Package_modify_date'] = packageModifyDate;
    return data;
  }

  // Static method to parse a list of data from JSON
  static List<VendorPackages> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => VendorPackages.fromJson(json)).toList();
  }
}
