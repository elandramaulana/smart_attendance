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

    // Bangun path dengan query parameter jika month tidak null
    String path = Endpoints.listSick;
    if (month != null) {
      path += '?month=$month';
    }

    final resp = await _api.get(path);

    // Response langsung berupa List
    if (resp is! List) {
      throw Exception(
          'Failed to fetch cuti: Expected List but got ${resp.runtimeType}');
    }
    return (resp as List).map((e) {
      return SickPermitModel.fromJson(e as Map<String, dynamic>);
    }).toList();
  }
}
