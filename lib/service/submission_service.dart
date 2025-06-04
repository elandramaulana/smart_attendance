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
    }
  }

  /// Submit form (leave, izin, sakit) sesuai model [request]
  Future<void> submit(SubmissionRequest request) async {
    await _attachToken();
    final fields = request
        .toFormData()
        .map((key, value) => MapEntry(key, value.toString()));

    await _api.postFormData(
      Endpoints.submission,
      fields: fields,
    );
  }
}
