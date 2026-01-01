class AllProfileList {
  List<ProfilesList>? profilesList = [];
  int? totalRecords;

  AllProfileList({this.profilesList, this.totalRecords});

  AllProfileList.fromJson(Map<String, dynamic> json) {
    if (json['profilesList'] != null) {
      profilesList = <ProfilesList>[];
      json['profilesList'].forEach((v) {
        profilesList!.add(ProfilesList.fromJson(v));
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

class ProfilesList {
  int? userId;
  String? name;
  String? dateOfBirth;
  int? currentLocationCityId;
  String? cityName;
  String? profileImage;
  String? gender;
  String? maritalStatus;
  int? favCount;
  String? matLogo;
  String? matName;
  String? cast;
  String? favourite;
  String? age;
  String? countryName;
  String? stateName;
  String? occupation;
  String? callStatus;
  bool? blurProfileImage;
  int? profileCreatedBy;

  ProfilesList(
      {this.userId,
        this.name,
        this.dateOfBirth,
        this.currentLocationCityId,
        this.cityName,
        this.profileImage,
        this.gender,
        this.maritalStatus,
        this.favCount,
        this.matLogo,
        this.matName,
        this.cast,
        this.favourite,
        this.age,
        this.countryName,
        this.stateName,
        this.occupation,
        this.callStatus,
        this.blurProfileImage,
        this.profileCreatedBy});

  ProfilesList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    dateOfBirth = json['date_of_birth'];
    currentLocationCityId = json['current_location_city_id'];
    cityName = json['city_name'];
    profileImage = json['profileImage'];
    gender = json['gender'];
    maritalStatus = json['marital_status'];
    favCount = json['fav_count'];
    matLogo = json['mat_logo'];
    matName = json['mat_name'];
    cast = json['cast'];
    favourite = json['favourite'];
    age = json['age'];
    countryName = json['CountryName'];
    stateName = json['StateName'];
    occupation = json['occupation'];
    callStatus = json['call_status'];
    blurProfileImage = json['is_blur'] ?? false;
    // Check both possible field names from API
    profileCreatedBy = json['profile_createdby'] ?? json['profile_created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = name;
    data['date_of_birth'] = dateOfBirth;
    data['current_location_city_id'] = currentLocationCityId;
    data['city_name'] = cityName;
    data['profileImage'] = profileImage;
    data['gender'] = gender;
    data['marital_status'] = maritalStatus;
    data['fav_count'] = favCount;
    data['mat_logo'] = matLogo;
    data['mat_name'] = matName;
    data['cast'] = cast;
    data['favourite'] = favourite;
    data['age'] = age;
    data['CountryName'] = countryName;
    data['StateName'] = stateName;
    data['occupation'] = occupation;
    data['call_status'] = callStatus;
    data['is_blur'] = blurProfileImage;
    data['profile_created_by'] = profileCreatedBy;
    return data;
  }
}