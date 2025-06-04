// lib/service/correction_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/correction_history_model.dart';
import 'package:smart_attendance/model/correctionr_req_model.dart';

class CorrectionService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      _api.setBearerToken(token);
    }
  }

  Future<CorrectionResponse> submitCorrection(CorrectionRequest req) async {
    await _attachToken();
    final response = await _api.postFormData(
      Endpoints.correction,
      fields: req.toFormData().map((k, v) => MapEntry(k, v.toString())),
    );
    return CorrectionResponse.fromJson(response);
  }

  Future<List<CorrectionListModel>> getCorrection({String? month}) async {
    await _attachToken();

    final response = await _api.postFormData(
      Endpoints.historyCorrection,
      fields: month != null ? {'month': month} : null,
    );
    if (response['success'] != true) {
      throw Exception('Failed to fetch cuti');
    }
    final rawData = response['data'];
    if (rawData == null || rawData is! List) {
      return <CorrectionListModel>[];
    }

    final List listData = rawData as List;

    return listData
        .map((e) => CorrectionListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
