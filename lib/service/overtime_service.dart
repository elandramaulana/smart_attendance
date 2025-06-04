import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/overtime_list_model.dart';
import 'package:smart_attendance/model/overtime_model.dart';

class OvertimeService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      _api.setBearerToken(token);
    }
  }

  Future<void> submitOvertime(Overtime overtime) async {
    await _attachToken();
    final response = await _api.postFormData(
      Endpoints.overtime,
      fields: overtime.toJson(),
    );
    return response;
  }

  Future<List<OvertimeListModel>> getOvertimes({String? month}) async {
    await _attachToken();

    final allFields = <String, String>{
      'month': month ?? '',
    };

    final resp = await _api.postFormData(
      Endpoints.overtimeList,
      fields: allFields,
    );

    if (resp['success'] != true) {
      throw Exception('Failed to fetch overtime');
    }

    final raw = resp['data'];
    if (raw == null || raw is! List) return [];
    return (raw as List)
        .map((e) => OvertimeListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
