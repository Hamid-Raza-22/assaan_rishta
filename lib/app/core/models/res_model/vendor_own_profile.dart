/// Model for Vendor Own Profile response from GetVendorOwnProfile API
class VendorOwnProfile {
  int? venderId;
  String? venderBusinessName;
  String? venderEmail;
  String? venderPhone;
  int? roleId;
  String? aboutCompany;
  String? serviceCharges;
  String? venderAddress;
  String? logo;
  String? vendorStateName;
  String? vendorCountryName;
  String? vendorCityName;
  String? vendorCategoryName;
  String? createdDate;

  VendorOwnProfile({
    this.venderId,
    this.venderBusinessName,
    this.venderEmail,
    this.venderPhone,
    this.roleId,
    this.aboutCompany,
    this.serviceCharges,
    this.venderAddress,
    this.logo,
    this.vendorStateName,
    this.vendorCountryName,
    this.vendorCityName,
    this.vendorCategoryName,
    this.createdDate,
  });

  VendorOwnProfile.fromJson(Map<String, dynamic> json) {
    venderId = json['Vender_ID'];
    venderBusinessName = json['Vender_business_name'];
    venderEmail = json['Vender_email'];
    venderPhone = json['Vender_phone'];
    roleId = json['role_id'];
    aboutCompany = json['about_company'];
    serviceCharges = json['service_charges'];
    venderAddress = json['Vender_address'];
    logo = json['logo'];
    vendorStateName = json['VendorStateName'];
    vendorCountryName = json['VendorCountryName'];
    vendorCityName = json['VendorCityName'];
    vendorCategoryName = json['VendorCategoryName'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Vender_ID'] = venderId;
    data['Vender_business_name'] = venderBusinessName;
    data['Vender_email'] = venderEmail;
    data['Vender_phone'] = venderPhone;
    data['role_id'] = roleId;
    data['about_company'] = aboutCompany;
    data['service_charges'] = serviceCharges;
    data['Vender_address'] = venderAddress;
    data['logo'] = logo;
    data['VendorStateName'] = vendorStateName;
    data['VendorCountryName'] = vendorCountryName;
    data['VendorCityName'] = vendorCityName;
    data['VendorCategoryName'] = vendorCategoryName;
    data['createdDate'] = createdDate;
    return data;
  }

  /// Get display name for vendor
  String get displayName => venderBusinessName ?? 'Vendor';

  /// Get location string
  String get location {
    final parts = <String>[];
    if (vendorCityName != null && vendorCityName!.isNotEmpty) {
      parts.add(vendorCityName!);
    }
    if (vendorStateName != null && vendorStateName!.isNotEmpty) {
      parts.add(vendorStateName!);
    }
    if (vendorCountryName != null && vendorCountryName!.isNotEmpty) {
      parts.add(vendorCountryName!);
    }
    return parts.join(', ');
  }
}
