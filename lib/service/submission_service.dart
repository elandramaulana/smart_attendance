import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/submission_request.dart';

class SubmissionService {
  final ApiProvider _api;

  SubmissionService({ApiProvider? api}) : _api = api ?? ApiProvider();

  /// Lampirkan token Bearer di setiap request
  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      _api.setBearerToken(token);
      debugPrint('🔑 Token attached');
    } else {
      debugPrint('⚠️ No token found');
    }
  }

  /// Submit form cuti/leave
  Future<void> submitCuti(SubmissionRequest request) async {
    debugPrint('📤 Submitting CUTI request...');
    await _attachToken();

    final formData = request.toFormData();
    final fields =
        formData.map((key, value) => MapEntry(key, value.toString()));

    debugPrint('📋 Form fields:');
    fields.forEach((key, value) {
      if (key == 'lampiran') {
        debugPrint('  - $key: [base64, length: ${value.length}]');
      } else {
        debugPrint('  - $key: $value');
      }
    });

    await _api.postFormData(
      Endpoints.reqeuestCuti,
      fields: fields,
    );

    debugPrint('✅ CUTI submitted successfully');
  }

  /// Submit form sakit
  Future<void> submitSakit(SubmissionRequest request) async {
    debugPrint('\n=== 📤 SUBMITTING SAKIT ===');
    debugPrint('Endpoint: ${Endpoints.requestSick}');

    await _attachToken();

    final formData = request.toFormData();
    final fields =
        formData.map((key, value) => MapEntry(key, value.toString()));

    debugPrint('\n📋 Fields being sent:');
    fields.forEach((key, value) {
      if (key == 'lampiran') {
        debugPrint('  ✓ $key: [base64, ${value.length} chars]');
      } else {
        debugPrint('  ✓ $key: $value');
      }
    });
    debugPrint('Total fields: ${fields.length}\n');

    try {
      final response = await _api.postFormData(
        Endpoints.requestSick,
        fields: fields,
      );

      debugPrint('✅ API Response received');
      debugPrint('Response: $response');
      debugPrint('===========================\n');
    } catch (e) {
      debugPrint('❌ API Error: $e');
      debugPrint('===========================\n');
      rethrow;
    }
  }
}
