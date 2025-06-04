// lib/service/attendance_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/attendance_model.dart';
import 'package:smart_attendance/model/attendance_today_model.dart';

class AttendanceService {
  final ApiProvider _api;
  AttendanceService([ApiProvider? apiProvider])
      : _api = apiProvider ?? ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token?.isNotEmpty == true) {
      _api.setBearerToken(token!);
      print('[AttendanceService] Token attached: $token');
    }
  }

  Future<void> recordAttendance(AttendanceModel record) async {
    await _attachToken();
    final resp = await _api.postFormData(
      Endpoints.store_attendance,
      fields: record.toJson(),
    );
    print('[AttendanceService] recordAttendance response: $resp');
  }

  Future<AttendanceTodayModel> getTodayAttendance() async {
    await _attachToken();
    final raw = await _api.get(Endpoints.attendance_today);
    return AttendanceTodayModel.fromJson(raw as Map<String, dynamic>);
  }
}
