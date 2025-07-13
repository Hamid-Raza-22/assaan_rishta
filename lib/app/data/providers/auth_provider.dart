// lib/app/data/providers/auth_provider.dart
import 'package:get/get.dart';

import '../models/login_model.dart';
import '../models/user_model.dart';


class AuthProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://your-api-base-url.com';
    httpClient.timeout = Duration(seconds: 30);
  }

  Future<Response> signUp(UserModel user) async {
    return await post('/auth/signup', user.toJson());
  }
  Future<Response> login(LoginModel loginData) async {
    try {
      return await post('/auth/login', loginData.toJson());
    } catch (e) {
      return Response(statusCode: 500, body: {'error': e.toString()});
    }
  }
  Future<Response> checkEmailExists(String email) async {
    return await get('/auth/check-email?email=$email');
  }
}