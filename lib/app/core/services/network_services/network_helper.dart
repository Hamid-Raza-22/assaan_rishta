import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

abstract class NetworkHelper {
  Future<http.Response> get(String url, {Map<String, String>? headers});

  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    body,
    encoding,
    bool isEncode,
  });

  Future<http.Response> patch(String url, {Map headers, body, encoding});

  Future<http.Response> delete(String url, {Map headers});

  Future<http.Response> put(String url, {Map headers, body, encoding});

  Future<http.Response> postMultipartData(
    String uri, {
    Map<String, String>? fields,
    Map<String, String>? headers,
  });

  Future<http.Response> patchMultipartData(
      String uri, List<XFile> multipartBody,
      {Map<String, String>? headers});

  Future<Map> appendHeader({Map headers});

  Future<Map> appendHeaderForFile({Map headers});

  http.Response handleResponse(http.Response response);
}
