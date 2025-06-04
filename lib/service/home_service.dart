// lib/service/home_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/attendance_today_model.dart';

class HomeService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token?.isNotEmpty == true) {
      _api.setBearerToken(token!);
      print('[HomeService] Token attached: $token');
    } else {
      print('[HomeService] No token found');
    }
  }

  Future<AttendanceTodayModel> getTodayAttendance() async {
    await _attachToken();
    final raw = await _api.get(Endpoints.attendance_today);
    return AttendanceTodayModel.fromJson(raw as Map<String, dynamic>);
  }
}
