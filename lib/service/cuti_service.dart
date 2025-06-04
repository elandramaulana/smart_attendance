import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/cuti_model.dart';

class CutiService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      _api.setBearerToken(token);
    }
  }

  Future<List<CutiModel>> getCuti({String? month}) async {
    await _attachToken();

    final response = await _api.postFormData(
      Endpoints.cuti,
      fields: month != null ? {'month': month} : null,
    );
    if (response['success'] != true) {
      throw Exception('Failed to fetch cuti');
    }
    final rawData = response['data'];
    if (rawData == null || rawData is! List) {
      return <CutiModel>[];
    }

    final List listData = rawData as List;

    return listData
        .map((e) => CutiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
