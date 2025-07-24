class DonorClaims {
  int? userId;
  String? firstName;
  String? lastName;
  String? gender;
  String? dateOfBirth;
  String? religion;
  String? country;
  String? email;
  String? password;
  String? status;
  int? roleId;
  String? role;
  String? roleName;
  String? mobileNo;
  String? caste;
  String? maritalStatus;
  String? height;
  String? education;
  String? occupation;
  int? profileCreatedby;
  String? userImage;
  String? profiledata;
  String? city;
  int? age;
  String? venderPhone;
  String? aboutCompany;
  String? venderCity;
  String? venderAddress;
  int? profileCount;
  String? aboutPartener;
  String? profileViewCounter;
  String? favouriteCount;
  String? userKaTaruf;
  String? userDiWohtiKaTaruf;
  String? catename;

  DonorClaims({
    this.userId,
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.religion,
    this.country,
    this.email,
    this.password,
    this.status,
    this.roleId,
    this.role,
    this.roleName,
    this.mobileNo,
    this.caste,
    this.maritalStatus,
    this.height,
    this.education,
    this.occupation,
    this.profileCreatedby,
    this.userImage,
    this.profiledata,
    this.city,
    this.age,
    this.venderPhone,
    this.aboutCompany,
    this.venderCity,
    this.venderAddress,
    this.profileCount,
    this.aboutPartener,
    this.profileViewCounter,
    this.favouriteCount,
    this.userKaTaruf,
    this.userDiWohtiKaTaruf,
    this.catename,
  });

  DonorClaims.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    religion = json['religion'];
    country = json['country'];
    email = json['email'];
    password = json['password'];
    status = json['status'];
    roleId = json['role_id'];
    role = json['role'];
    roleName = json['RoleName'];
    mobileNo = json['mobile_no'];
    caste = json['caste'];
    maritalStatus = json['marital_status'];
    height = json['height'];
    education = json['education'];
    occupation = json['occupation'];
    profileCreatedby = json['profile_createdby'];
    userImage = json['user_image'];
    profiledata = json['profiledata'];
    city = json['city'];
    age = json['age'];
    venderPhone = json['Vender_phone'];
    aboutCompany = json['about_company'];
    venderCity = json['Vender_city'];
    venderAddress = json['Vender_address'];
    profileCount = json['profileCount'];
    aboutPartener = json['aboutPartener'];
    profileViewCounter = json['ProfileViewCounter'];
    favouriteCount = json['FavouriteCount'];
    userKaTaruf = json['userKaTaruf'];
    userDiWohtiKaTaruf = json['userDiWohtiKaTaruf'];
    catename = json['catename'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['gender'] = gender;
    data['date_of_birth'] = dateOfBirth;
    data['religion'] = religion;
    data['country'] = country;
    data['email'] = email;
    data['password'] = password;
    data['status'] = status;
    data['role_id'] = roleId;
    data['role'] = role;
    data['RoleName'] = roleName;
    data['mobile_no'] = mobileNo;
    data['caste'] = caste;
    data['marital_status'] = maritalStatus;
    data['height'] = height;
    data['education'] = education;
    data['occupation'] = occupation;
    data['profile_createdby'] = profileCreatedby;
    data['user_image'] = userImage;
    data['profiledata'] = profiledata;
    data['city'] = city;
    data['age'] = age;
    data['Vender_phone'] = venderPhone;
    data['about_company'] = aboutCompany;
    data['Vender_city'] = venderCity;
    data['Vender_address'] = venderAddress;
    data['profileCount'] = profileCount;
    data['aboutPartener'] = aboutPartener;
    data['ProfileViewCounter'] = profileViewCounter;
    data['FavouriteCount'] = favouriteCount;
    data['userKaTaruf'] = userKaTaruf;
    data['userDiWohtiKaTaruf'] = userDiWohtiKaTaruf;
    data['catename'] = catename;
    return data;
  }
}
