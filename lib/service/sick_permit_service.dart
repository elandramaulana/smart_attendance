// lib/service/absence_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/sick_permit_model.dart';

class SickPermitService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) _api.setBearerToken(token);
  }

  /// Ambil semua absence (Izin + Sakit), dengan optional filter month "YYYY-MM".
  Future<List<SickPermitModel>> getAbsences({String? month}) async {
    await _attachToken();
    final resp = await _api.postFormData(
      Endpoints.sickPermit,
      fields: month != null ? {'month': month} : null,
    );
    if (resp['success'] != true) {
      throw Exception('Failed to fetch absence');
    }

    final raw = resp['data'];
    if (raw == null || raw is! List) return [];
    return (raw as List)
        .map((e) => SickPermitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
