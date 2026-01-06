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

  /// Record attendance dengan base64 string (sesuai backend)
  Future<void> recordAttendance(AttendanceModel record) async {
    await _attachToken();
    print('[AttendanceService] Recording attendance...');
    print('[AttendanceService] Session: ${record.attSession}');

    try {
      if (record.selfie == null || record.selfie!.isEmpty) {
        throw Exception('Selfie data is required');
      }

      print('[AttendanceService] Preparing form data...');
      final formData = record.toJson();
      print('[AttendanceService] Form fields: ${formData.keys.toList()}');
      print(
          '[AttendanceService] Selfie size: ${(record.selfie!.length / 1024).toStringAsFixed(2)} KB');

      print('[AttendanceService] Sending to ${Endpoints.store_attendance}...');
      final response = await _api.postFormData(
        Endpoints.store_attendance,
        fields: formData,
      );

      print('[AttendanceService] ✅ Success: $response');
    } catch (e, stackTrace) {
      print('[AttendanceService] ❌ Error: $e');
      print('[AttendanceService] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<AttendanceTodayModel> getTodayAttendance() async {
    await _attachToken();
    print('[AttendanceService] Fetching today attendance...');

    try {
      final raw = await _api.get(Endpoints.attendance_today);
      print('[AttendanceService] Today attendance fetched successfully');
      return AttendanceTodayModel.fromJson(raw as Map<String, dynamic>);
    } catch (e) {
      print('[AttendanceService] Error fetching today attendance: $e');
      rethrow;
    }
  }
}
