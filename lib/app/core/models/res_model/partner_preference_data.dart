class PartnerPreferenceData {
  int? partnerId;
  int? partnerAgeFrom;
  String? partnerHeight;
  String? partnerBuilt;
  String? partnerMaritalStatus;
  String? partnerMotherTounge;
  String? partnerReligion;
  String? partnerCaste;
  String? partnerSmokeHabbit;
  String? partnerDrinkHabbit;
  String? partnerEducation;
  String? partnerOccupation;
  int? partnerCity;
  String? aboutParentCityName;
  String? partnerAnnualIncome;
  String? aboutPartner;
  int? partnerAgeTo;
  String? partnerComplexion;
  String? partnerLanguages;
  String? aboutStateName;
  String? aboutCountryName;
  int? aboutStateId;
  int? aboutCountryId;
  int? aboutParentCityId;
  int? userId;

  PartnerPreferenceData({
    this.partnerId,
    this.partnerAgeFrom,
    this.partnerHeight,
    this.partnerBuilt,
    this.partnerMaritalStatus,
    this.partnerMotherTounge,
    this.partnerReligion,
    this.partnerCaste,
    this.partnerSmokeHabbit,
    this.partnerDrinkHabbit,
    this.partnerEducation,
    this.partnerOccupation,
    this.partnerCity,
    this.aboutParentCityName,
    this.partnerAnnualIncome,
    this.aboutPartner,
    this.partnerAgeTo,
    this.partnerComplexion,
    this.partnerLanguages,
    this.aboutStateName,
    this.aboutCountryName,
    this.aboutStateId,
    this.aboutCountryId,
    this.aboutParentCityId,
    this.userId,
  });

  PartnerPreferenceData.fromJson(Map<String, dynamic> json) {
    partnerId = json['partner_id'];
    partnerAgeFrom = json['partner_age_from'];
    partnerHeight = json['partner_height'];
    partnerBuilt = json['partner_built'];
    partnerMaritalStatus = json['partner_marital_status'];
    partnerMotherTounge = json['partner_mother_tounge'];
    partnerReligion = json['partner_religion'];
    partnerCaste = json['partner_caste'];
    partnerSmokeHabbit = json['partner_smoke_habbit'];
    partnerDrinkHabbit = json['partner_drink_habbit'];
    partnerEducation = json['partner_education'];
    partnerOccupation = json['partner_occupation'];
    partnerCity = json['partner_city'];
    aboutParentCityName = json['aboutParentCityName'];
    partnerAnnualIncome = json['partner_annual_income'];
    aboutPartner = json['about_partner'];
    partnerAgeTo = json['partner_age_to'];
    partnerComplexion = json['partner_complexion'];
    partnerLanguages = json['partnerLanguages'];
    aboutStateName = json['aboutStateName'];
    aboutCountryName = json['aboutCountryName'];
    aboutStateId = json['aboutStateId'];
    aboutCountryId = json['aboutCountryId'];
    aboutParentCityId = json['aboutParentCityId'];
    userId = json['user_id'];
  }
}
