import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/map_attendance.dart';

class MapAttendanceService {
  final _api = ApiProvider();

  MapAttendanceService();

  Future<void> _attachToken() async {
    print('[MapService] Attaching token from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      _api.setBearerToken(token);
      // Cetak token penuh (tanpa substring)
      print('[MapService] Token attached (full): $token');
    } else {
      print('[MapService] No token found in SharedPreferences.');
    }
  }

  Future<MapAttendance> getMapAttendance() async {
    print('[MapAttendanceService] getMapAttendance() called');
    await _attachToken();
    print('[MapAttendanceService] GET ${Endpoints.getOfficeInfo}');
    final raw = await _api.get(Endpoints.getOfficeInfo);
    print('[MapAttendanceService] Response received: $raw');
    final json = raw as Map<String, dynamic>;
    final mapAttendance = MapAttendance.fromJson(json);
    return mapAttendance;
  }
}
