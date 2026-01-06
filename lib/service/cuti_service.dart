import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/cuti_model.dart';

class CutiService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) _api.setBearerToken(token);
  }

  Future<List<CutiModel>> getCuti({String? month}) async {
    await _attachToken();

    String path = Endpoints.listCuti;
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
      return CutiModel.fromJson(e as Map<String, dynamic>);
    }).toList();
  }
}
