// lib/app/data/providers/auth_provider.dart
import 'package:get/get.dart';

import '../../core/services/env_config_service.dart';
import '../models/login_model.dart';
import '../models/user_model.dart';

class AuthProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = EnvConfig.baseUrl;
    httpClient.timeout = Duration(seconds: 30);
  }

  Future<Response> signUp(SignUpModel user) async {
    try {
    return await post('Users/registerUser', user.toJson());
    } catch (e) {
      return Response(statusCode: 500, body: {'error': e.toString()});
    }
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

  Future<Response> reportUser({
    required String message,
    required String reporterNumber,
    required String reporterName,
    required String reportDateIso,
    required int reportedUserId,
  }) async {
    try {
      final payload = {
        'massege': message,
        'reporter_number': reporterNumber,
        'reporter_name': reporterName,
        'report_date': reportDateIso,
        'reported_user_id': reportedUserId,
      };
      return await post('Users/reportUser', payload);
    } catch (e) {
      return Response(statusCode: 500, body: {'error': e.toString()});
    }
  }
}
