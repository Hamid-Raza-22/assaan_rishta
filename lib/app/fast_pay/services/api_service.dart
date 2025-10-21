import 'package:dio/dio.dart';
import '../../core/services/env_config_service.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<String> getToken(String basketId, String amount) async {
    _dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
    ));
    try {
      final response = await _dio.get(
        '${EnvConfig.baseUrl}PayFastController/GetToken/$basketId/$amount/PKR',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500; // allow 3xx, 4xx
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['token'];
      }else{
        throw Exception('Failed to get token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting token: $e');
    }
  }
}
