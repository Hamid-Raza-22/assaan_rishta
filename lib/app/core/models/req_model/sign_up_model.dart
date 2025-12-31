class SignUpModel {
  String catename;
  String firstName;
  String lastName;
  String dateOfBirth;
  String email;
  String gender;
  String password;
  String religion;
  String caste;
  String mobileNo;
  String maritalStatus;
  String height;
  String education;
  int city;
  String occupation;
  bool terms;
  String userKaTaruf;
  String userDiWohtiKaTaruf;
  int roleId;
  String? profilePhotoPath; // Optional photo file path (for local reference)
  String? profilePhotoBase64; // Optional photo base64 data (for server upload)
  bool profileBlur;
  int? profileCreatedBy; // Admin user ID who created this profile
  SignUpModel({
    required this.catename,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.gender,
    required this.password,
    required this.religion,
    required this.caste,
    required this.mobileNo,
    required this.maritalStatus,
    required this.height,
    required this.education,
    required this.city,
    required this.occupation,
    required this.terms,
    required this.userKaTaruf,
    required this.userDiWohtiKaTaruf,
    required this.roleId,
    this.profilePhotoPath, // Optional parameter
    this.profilePhotoBase64, // Optional parameter
    this.profileBlur = false,
    this.profileCreatedBy, // Optional parameter for admin registration
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      catename: json['catename'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: json['date_of_birth'],
      email: json['email'],
      gender: json['gender'],
      password: json['password'],
      religion: json['religion'],
      caste: json['caste'],
      mobileNo: json['mobile_no'],
      maritalStatus: json['marital_status'],
      height: json['height'],
      education: json['education'],
      city: json['city'],
      occupation: json['occupation'],
      terms: json['terms'],
      userKaTaruf: json['userKaTaruf'],
      userDiWohtiKaTaruf: json['userDiWohtiKaTaruf'],
      roleId: json['role_id'],
      profileBlur: json['is_blur'] ?? false,
      profileCreatedBy: json['profile_createdby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catename': catename,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'email': email,
      'gender': gender,
      'password': password,
      'religion': religion,
      'caste': caste,
      'mobile_no': mobileNo,
      'marital_status': maritalStatus,
      'height': height,
      'education': education,
      'city': city,
      'occupation': occupation,
      'terms': terms,
      'userKaTaruf': userKaTaruf,
      'userDiWohtiKaTaruf': userDiWohtiKaTaruf,
      'role_id': roleId,
      if (profilePhotoBase64 != null && profilePhotoBase64!.isNotEmpty)
        'user_image': profilePhotoBase64,
      'is_blur': profileBlur,
      if (profileCreatedBy != null && profileCreatedBy! > 0)
        'profile_createdby': profileCreatedBy,
    };
  }
}
