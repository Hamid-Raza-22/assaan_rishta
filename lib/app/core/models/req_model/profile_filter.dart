class ProfileFilter {
  String? ageFrom;
  String? ageTo;
  String? caste;
  String? city;
  String? gender;
  String? maritalStatus;
  String? religion;
  int? pageNumber;
  int? pageSize;
  int? userId;
  String? searchUserId; // New field for user ID search


  ProfileFilter({
    this.ageFrom,
    this.ageTo,
    this.caste,
    this.city,
    this.gender,
    this.maritalStatus,
    this.religion,
    this.pageNumber,
    this.pageSize,
    this.userId,
    this.searchUserId, // New field for user ID search
  });

  ProfileFilter.fromJson(Map<String, dynamic> json) {
    ageFrom = json['age_from'];
    ageTo = json['age_to'];
    caste = json['caste'];
    city = json['city'];
    gender = json['gender'];
    maritalStatus = json['maritalStatus'];
    religion = json['religion'];
    pageNumber = json['pageNumber'];
    pageSize = json['PageSize'];
    userId = json['userId'];
    searchUserId = json['searchUserId']; // New field for user ID search
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age_from'] = ageFrom;
    data['age_to'] = ageTo;
    data['caste'] = caste;
    data['city'] = city;
    data['gender'] = gender;
    data['maritalStatus'] = maritalStatus;
    data['religion'] = religion;
    data['pageNumber'] = pageNumber;
    data['PageSize'] = pageSize;
    data['userId'] = userId;
    data['searchUserId'] = searchUserId; // New field for user ID search
    return data;
  }
}
