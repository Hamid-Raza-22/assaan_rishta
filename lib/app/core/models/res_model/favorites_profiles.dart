class FavoritesProfiles {
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

  FavoritesProfiles(
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
        this.callStatus});

  FavoritesProfiles.fromJson(Map<String, dynamic> json) {
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
    return data;
  }

  // Static method to parse a list of countries from JSON
  static List<FavoritesProfiles> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FavoritesProfiles.fromJson(json)).toList();
  }
}
