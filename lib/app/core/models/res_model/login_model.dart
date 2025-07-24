class LoginModel {
  String? accessToken;
  String? tokenType;
  int? expiresIn;

  LoginModel({this.accessToken, this.tokenType, this.expiresIn});

  LoginModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    expiresIn = json['expires_in'];
  }

}

class LoginError {
  String? error;

  LoginError({this.error});

  LoginError.fromJson(Map<String, dynamic> json) {
    error = json['error'];
  }
}
