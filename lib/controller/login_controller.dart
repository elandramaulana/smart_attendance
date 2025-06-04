import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/service/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final isLoading = false.obs;
  final error = RxnString();

  LoginController(ApiProvider api) : _authService = AuthService(api) {
    _init();
  }

  void _init() async {
    final token = await _authService.getToken();
    if (token != null) {
      _authService.api.setBearerToken(token);
    }
  }

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan Password tidak boleh kosong');
      return;
    }

    isLoading(true);
    error.value = null;
    try {
      await _authService.login(email, password);
      Get.snackbar('Success', 'Login berhasil');
      Get.toNamed(AppRoutes.bottomNav);
    } catch (e) {
      error(e.toString());
      Get.snackbar('Error', error.value ?? 'Login gagal');
    } finally {
      isLoading(false);
    }
  }

  void logout() async {
    await _authService.logout();
    Get.snackbar('Success', 'Logout berhasil');
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }
}
