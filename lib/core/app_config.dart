import 'package:package_info_plus/package_info_plus.dart';

enum Environment { development, staging, production }

/// Application configuration for different environments
class AppConfig {
  /// Current environment
  static Environment env = Environment.staging;
  static String version = '';
  static String buildNumber = '';

  /// Base URLs for each environment
  static const _baseUrls = {
    Environment.staging: 'https://absensi.karyalin.com/api',
    Environment.production: 'https://api.example.com',
  };

  /// Get current base URL
  static String get baseUrl => _baseUrls[env]!;

  /// Other global configs
  static const int requestTimeoutSeconds = 30;
  static const bool enableLogging = true;

  static Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version; // contohnya "1.2.3"
    buildNumber = info.buildNumber; // contohnya "45"
  }
}

/// Endpoint paths
class Endpoints {
  static const String login = '/login';
  static const String profile = '/me';
  static const String getOfficeInfo = '/get_office_info';
  static const String store_attendance = '/record_attendance';
  static const String attendance_today = '/attendance/user/today';
  static const String correction = '/attendance/user/correction';
  static const String submission = '/submissions';
  static const String approval = '/approval_list';
  static const String approvalAction = '/approval_action';
  static const String overtime = '/user/store_overtime';
  static const String updateProfile = '/change_photo';
  static const String cuti = '/user/leave_history';
  static const String sickPermit = '/user/sick_history';
  static const String overtimeList = '/user/overtime_history';
  static const String historyCorrection = '/user/attendance_corrections';
}
