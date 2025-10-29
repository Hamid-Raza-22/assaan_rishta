import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage_services/storage_keys.dart';
import 'network_helper.dart';


class NetworkHelperImpl extends NetworkHelper {
  NetworkHelperImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  @override
  Future<http.Response> get(String url, {
    Map<String, String>? headers,
  }) async {
    debugPrint('----GET REQUEST----\nURL --> $url');
    // final header = await appendHeader(headers: headers);
    return http.get(Uri.parse(url), headers: headers).then((
        http.Response response,) async {
      debugPrint(
          '----GET RESPONSE----\nURL --> $url\nStatus Code = ${response
              .statusCode}\nbody = ${response.body.toString()}');

      return handleResponse(response);
    }).catchError((error) {
      throw (error);
    });
  }

  @override
  Future<http.Response> post(String url, {
    Map<String, String>? headers,
    body,
    encoding,
    bool isEncode = true,
  }) async {
    debugPrint(
        '----POST REQUEST----\nURL --> $url\nBody --> ${isEncode ? json.encode(
            body) : body}');
    return http
        .post(
      Uri.parse(url),
      body: isEncode ? json.encode(body) : body,
      headers: headers,
      encoding: encoding,
    )
        .then((http.Response response) {
      debugPrint(
          '----POST RESPONSE----\nURL --> $url\nStatus Code = ${response
              .statusCode}\nbody = ${response.body.toString()}');
      return handleResponse(response);
    }).catchError((error) {
      debugPrint('...................');
      throw (error);
    });
  }

  @override
  Future<http.Response> patch(String url,
      {Map? headers, body, encoding}) async {
    debugPrint('----PATCH REQUEST----\nURL --> $url\nBody --> $body');
    final header = await appendHeader(headers: headers);
    return http
        .patch(Uri.parse(url),
        body: json.encode(body), headers: header, encoding: encoding)
        .then((http.Response response) {
      debugPrint(
          '----PATCH RESPONSE----\nURL --> $url\nStatus Code = ${response
              .statusCode}\nbody = ${response.body.toString()}');
      return handleResponse(response);
    }).catchError((error) {
      throw (error);
    });
  }

  @override
  Future<http.Response> delete(String url, {Map? headers}) async {
    final header = await appendHeader(headers: headers);
    return http
        .delete(Uri.parse(url), headers: header)
        .then((http.Response response) {
      debugPrint(
          '----DELETE RESPONSE----\nURL --> $url\nStatus Code = ${response
              .statusCode}\nbody = ${response.body.toString()}');
      return handleResponse(response);
    }).catchError((error) {
      throw (error);
    });
  }

  @override
  Future<http.Response> put(String url, {Map? headers, body, encoding}) async {
    final header = await appendHeader(headers: headers);

    return http
        .put(Uri.parse(url),
        body: json.encode(body), headers: header, encoding: encoding)
        .then(
          (http.Response response) {
        debugPrint(
            '----PUT RESPONSE----\nURL --> $url\nStatus Code = ${response
                .statusCode}\nbody = ${response.body.toString()}');

        return handleResponse(response);
      },
    ).catchError((error) {
      throw (error);
    });
  }

  @override
  http.Response handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    switch (statusCode) {
      case 401:
        {
          throw Exception("Unauthorized");
        }
      case 500:
        {
          throw Exception("Internal server error");
        }
      default:
        return response;
    }
  }

  @override
  Future<Map<String, String>> appendHeader({
    Map? headers,
    bool refresh = false,
    bool accessToken = false,
  }) async {
    try {
      headers ??= <String, String>{};
      headers["Content-Type"] = "application/x-www-form-urlencoded";
      headers["Authorization"] =
      "Bearer ${sharedPreferences.get(StorageKeys.token)}";
    } catch (e) {
      debugPrint(e.toString());
    }

    return headers as Map<String, String>;
  }

  @override
  Future<Map<String, String>> appendHeaderForFile(
      {Map? headers, bool refresh = false, bool accessToken = false}) async {
    try {
      headers ??= <String, String>{};
      headers["Content-Type"] = "multipart/form-data";
      headers["Authorization"] =
      "Bearer ${sharedPreferences.get(StorageKeys.token)}";
    } catch (e) {
      debugPrint(e.toString());
    }

    return headers as Map<String, String>;
  }

  @override
  Future<http.Response> postMultipartData(
      String uri, {
        Map<String, String>? fields,
        Map<String, String>? headers
      }
      ) async {
    if (kDebugMode) {
      print('====> API Call: $uri\nHeader: $headers');
    }
    http.MultipartRequest request =
    http.MultipartRequest('POST', Uri.parse(uri));
    request.headers.addAll(headers!);
    request.fields.addAll(fields!);
    http.Response response =
    await http.Response.fromStream(await request.send());
    return handleResponse(response);
  }

  @override
  Future<http.Response> patchMultipartData(String uri,
      List<XFile> multipartBody,
      {Map<String, String>? headers}) async {
    if (kDebugMode) {
      print('====> API Call: $uri\nHeader: $headers');
    }
    http.MultipartRequest request =
    http.MultipartRequest('PATCH', Uri.parse(uri));
    final header = await appendHeaderForFile(headers: headers);
    request.headers.addAll(header);
    for (int i = 0; i < multipartBody.length; i++) {
      var file = await http.MultipartFile.fromPath(
          'image', multipartBody[i].path,
          contentType: MediaType('image', 'png'));
      request.files.add(file);
    }
    http.Response response =
    await http.Response.fromStream(await request.send());
    return handleResponse(response);
  }

  MediaType getMediaType(String filename) {
    final extension = filename
        .split('.')
        .last
        .toLowerCase();
    switch (extension) {
      case 'jpeg':
      case 'jpg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        throw UnsupportedError('Unsupported image format');
    }
  }
}