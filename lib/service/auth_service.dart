import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/core/base_provider.dart';

class AuthService {
  final ApiProvider api;
  AuthService(this.api);

  /// Login user and store token + approval status + user_id
  Future<void> login(String email, String password) async {
    final res = await api.postFormData(
      Endpoints.login,
      fields: {'email': email, 'password': password},
    );

    // --- Ambil token dari response ---
    final token = res['access_token'] as String?;
    if (token == null) {
      throw Exception('Login failed: no access_token');
    }

    // --- Ambil status approval dari response ---
    final approvalFlag = res['is_approval'];
    bool isApproved;
    if (approvalFlag is bool) {
      isApproved = approvalFlag;
    } else if (approvalFlag is String) {
      isApproved = approvalFlag.toLowerCase() == 'true';
    } else if (approvalFlag is num) {
      isApproved = approvalFlag == 1;
    } else {
      isApproved = false;
    }

    // --- Ambil user_id dari response (bisa int atau String) ---
    final userIdValue = res['user_id'];
    int userId;
    if (userIdValue is int) {
      userId = userIdValue;
    } else if (userIdValue is String) {
      userId = int.tryParse(userIdValue) ??
          (throw Exception('Login failed: invalid user_id format'));
    } else {
      throw Exception('Login failed: no user_id');
    }

    // --- Simpan ke SharedPreferences ---
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setBool('is_approval', isApproved);
    await prefs.setInt('user_id', userId);

    // --- Set token di memory API ---
    api.setBearerToken(token);
  }

  /// Ambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Ambil status approval user
  Future<bool> getApprovalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_approval') ?? false;
  }

  /// Ambil user_id dari SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  /// Logout user dan bersihkan data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_approval');
    await prefs.remove('user_id');
    api.setBearerToken(''); // hapus token di memory juga
    Get.offAllNamed(AppRoutes.login);
  }
}
