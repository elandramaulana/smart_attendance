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
    final headers = {
      'Accept': 'application/json',
      'User-Agent': 'SmartAttendance/1.0 (Android)', // TAMBAH INI
      'X-Requested-With': 'XMLHttpRequest', // TAMBAH INI
      ...?custom
    };
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

  // PERBAIKAN: Kirim base64 dengan chunking untuk menghindari WAF
  Future<dynamic> postFormData(String path,
      {Map<String, String>? fields, Map<String, String>? headers}) async {
    print('[ApiProvider] postFormData → $path');
    print('[ApiProvider] Fields count: ${fields?.length ?? 0}');

    // Check if selfie field is too large
    if (fields != null && fields.containsKey('selfie')) {
      final selfieLength = fields['selfie']?.length ?? 0;
      print('[ApiProvider] Selfie field length: $selfieLength characters');
      print(
          '[ApiProvider] Selfie size: ${(selfieLength / 1024).toStringAsFixed(2)} KB');
    }

    final req = http.MultipartRequest('POST', _buildUri(path))
      ..headers.addAll(_buildHeaders(headers))
      ..fields.addAll(fields ?? {});

    print('[ApiProvider] Request headers: ${req.headers}');
    print('[ApiProvider] Sending request...');

    try {
      final streamed = await req
          .send()
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      print('[ApiProvider] Response status: ${streamed.statusCode}');
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 403) {
        print(
            '[ApiProvider] 403 Error - Response body: ${res.body.substring(0, 200)}...');
      }

      return _processResponse(res);
    } catch (e) {
      print('[ApiProvider] Error in postFormData: $e');
      rethrow;
    }
  }

  Future<dynamic> postFormDataWithImage(String path,
      {Map<String, String>? fields,
      required File imageFile,
      String imageFieldName = 'image',
      Map<String, String>? headers}) async {
    print('[ApiProvider] postFormDataWithImage → $path');
    print('[ApiProvider] Image field name: $imageFieldName');
    print('[ApiProvider] Image path: ${imageFile.path}');
    print('[ApiProvider] Fields: ${fields?.keys.toList()}');

    final req = http.MultipartRequest('POST', _buildUri(path))
      ..headers.addAll(_buildHeaders(headers))
      ..fields.addAll(fields ?? {});

    final multipartFile = await http.MultipartFile.fromPath(
      imageFieldName,
      imageFile.path,
      filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    print('[ApiProvider] Multipart file size: ${multipartFile.length} bytes');
    req.files.add(multipartFile);

    print('[ApiProvider] Sending multipart request...');
    final streamed = await req
        .send()
        .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

    print('[ApiProvider] Response status: ${streamed.statusCode}');
    final res = await http.Response.fromStream(streamed);
    return _processResponse(res);
  }

  dynamic _processResponse(http.Response response) {
    final code = response.statusCode;
    final body = response.body;

    print('[ApiProvider] Response status: $code');

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
