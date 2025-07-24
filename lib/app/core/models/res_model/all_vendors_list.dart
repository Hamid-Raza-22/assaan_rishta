class AllVendorsList {
  List<VendorsList>? profilesList = [];
  int? totalRecords;

  AllVendorsList({this.profilesList, this.totalRecords});

  AllVendorsList.fromJson(Map<String, dynamic> json) {
    if (json['profilesList'] != null) {
      profilesList = <VendorsList>[];
      json['profilesList'].forEach((v) {
        profilesList!.add(VendorsList.fromJson(v));
      });
    }
    totalRecords = json['totalRecords'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (profilesList != null) {
      data['profilesList'] = profilesList!.map((v) => v.toJson()).toList();
    }
    data['totalRecords'] = totalRecords;
    return data;
  }
}

class VendorsList {
  int? venderID;
  String? venderBusinessName;
  String? venderEmail;
  String? venderPhone;
  String? venderPassword;
  int? venderCity;
  int? venderCatID;
  int? venderFeaturedCatID;
  int? roleId;
  String? aboutCompany;
  String? serviceCharges;
  String? terms;
  String? venderAddress;
  String? logo;
  int? vendorStateId;
  String? venderCatName;
  String? vendorStateName;
  String? vendorCountryName;
  int? vendorCountryId;
  String? vendorCityName;
  String? vendorCategoryName;
  String? callStatus;

  VendorsList(
      {this.venderID,
      this.venderBusinessName,
      this.venderEmail,
      this.venderPhone,
      this.venderPassword,
      this.venderCity,
      this.venderCatID,
      this.venderFeaturedCatID,
      this.roleId,
      this.aboutCompany,
      this.serviceCharges,
      this.terms,
      this.venderAddress,
      this.logo,
      this.vendorStateId,
      this.venderCatName,
      this.vendorStateName,
      this.vendorCountryName,
      this.vendorCountryId,
      this.vendorCityName,
      this.vendorCategoryName,
      this.callStatus});

  VendorsList.fromJson(Map<String, dynamic> json) {
    venderID = json['Vender_ID'];
    venderBusinessName = json['Vender_business_name'];
    venderEmail = json['Vender_email'];
    venderPhone = json['Vender_phone'];
    venderPassword = json['Vender_password'];
    venderCity = json['Vender_city'];
    venderCatID = json['Vender_cat_ID'];
    venderFeaturedCatID = json['Vender_featured_cat_ID'];
    roleId = json['role_id'];
    aboutCompany = json['about_company'];
    serviceCharges = json['service_charges'];
    terms = json['terms'];
    venderAddress = json['Vender_address'];
    logo = json['logo'];
    vendorStateId = json['VendorStateId'];
    venderCatName = json['Vender_cat_name'];
    vendorStateName = json['VendorStateName'];
    vendorCountryName = json['VendorCountryName'];
    vendorCountryId = json['VendorCountryId'];
    vendorCityName = json['VendorCityName'];
    vendorCategoryName = json['VendorCategoryName'];
    callStatus = json['call_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Vender_ID'] = venderID;
    data['Vender_business_name'] = venderBusinessName;
    data['Vender_email'] = venderEmail;
    data['Vender_phone'] = venderPhone;
    data['Vender_password'] = venderPassword;
    data['Vender_city'] = venderCity;
    data['Vender_cat_ID'] = venderCatID;
    data['Vender_featured_cat_ID'] = venderFeaturedCatID;
    data['role_id'] = roleId;
    data['about_company'] = aboutCompany;
    data['service_charges'] = serviceCharges;
    data['terms'] = terms;
    data['Vender_address'] = venderAddress;
    data['logo'] = logo;
    data['VendorStateId'] = vendorStateId;
    data['Vender_cat_name'] = venderCatName;
    data['VendorStateName'] = vendorStateName;
    data['VendorCountryName'] = vendorCountryName;
    data['VendorCountryId'] = vendorCountryId;
    data['VendorCityName'] = vendorCityName;
    data['VendorCategoryName'] = vendorCategoryName;
    data['call_status'] = callStatus;
    return data;
  }
}
