// lib/app/data/repositories/auth_repository.dart

import '../models/login_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider;

  AuthRepository(this._authProvider);

  Future<bool> signUp(UserModel user) async {
    final response = await _authProvider.signUp(user);
    return response.statusCode == 200;
  }
  Future<bool> login(LoginModel loginData) async {
    try {
      final response = await _authProvider.login(loginData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<bool> checkEmailExists(String email) async {
    final response = await _authProvider.checkEmailExists(email);
    return response.statusCode == 200 && response.body['exists'] == true;
  }
}