import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/core/app_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: HTTP $statusCode — $message';
}

class ApiProvider {
  String? _bearerToken;
  ApiProvider();

  void setBearerToken(String token) {
    _bearerToken = token;
  }

  Uri _buildUri(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Map<String, String> _buildHeaders([Map<String, String>? custom]) {
    final headers = {'Accept': 'application/json', ...?custom};
    if (_bearerToken != null) {
      headers['Authorization'] = 'Bearer $_bearerToken';
      print('[ApiProvider] Authorization header → Bearer $_bearerToken');
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final res = await http
        .get(_buildUri(path), headers: _buildHeaders(headers))
        .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
    return _processResponse(res);
  }

  Future<dynamic> postJson(String path,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final res = await http
        .post(
          _buildUri(path),
          headers:
              _buildHeaders({'Content-Type': 'application/json', ...?headers}),
          body: jsonEncode(body ?? {}),
        )
        .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
    return _processResponse(res);
  }

  Future<dynamic> postFormData(String path,
      {Map<String, String>? fields, Map<String, String>? headers}) async {
    final req = http.MultipartRequest('POST', _buildUri(path))
      ..headers.addAll(_buildHeaders(headers))
      ..fields.addAll(fields ?? {});
    final streamed = await req
        .send()
        .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
    final res = await http.Response.fromStream(streamed);
    return _processResponse(res);
  }

  Future<dynamic> postFormDataWithImage(String path,
      {Map<String, String>? fields,
      required File imageFile,
      String imageFieldName = 'image',
      Map<String, String>? headers}) async {
    final req = http.MultipartRequest('POST', _buildUri(path))
      ..headers.addAll(_buildHeaders(headers))
      ..fields.addAll(fields ?? {})
      ..files.add(
          await http.MultipartFile.fromPath(imageFieldName, imageFile.path));
    final streamed = await req
        .send()
        .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
    final res = await http.Response.fromStream(streamed);
    return _processResponse(res);
  }

  dynamic _processResponse(http.Response response) {
    final code = response.statusCode;
    final body = response.body;
    if (code >= 200 && code < 300) {
      if (body.isNotEmpty &&
          response.headers['content-type']?.contains('application/json') ==
              true) {
        return jsonDecode(body);
      }
      return body;
    }
    String msg;
    try {
      msg = jsonDecode(body)['message'] ?? body;
    } catch (_) {
      msg = body.isNotEmpty ? body : 'Unknown error';
    }
    throw ApiException(code, msg);
  }
}
