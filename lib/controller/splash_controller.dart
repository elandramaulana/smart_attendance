import 'package:get/get.dart';
import 'dart:async';

import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/service/auth_service.dart';

class SplashScreenController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  Future<void> onReady() async {
    super.onReady();

    // Beri sedikit delay untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Cek apakah token tersimpan
    final token = await _authService.getToken();

    if (token != null && token.isNotEmpty) {
      _authService.api.setBearerToken(token);

      // Route ke halaman utama
      Get.offNamed(AppRoutes.bottomNav);
    } else {
      // Route ke halaman login jika belum ada token
      Get.offNamed(AppRoutes.login);
    }
  }
}
