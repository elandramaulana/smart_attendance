import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/profile_model.dart';
import 'package:smart_attendance/service/auth_service.dart';
import 'package:smart_attendance/service/profile_service.dart';

class ProfileController extends GetxController {
  final _service = ProfileService();

  AuthService authService = Get.put(AuthService(Get.put(ApiProvider())));
  final ImagePicker _picker = ImagePicker();

  // state observables
  final RxBool isLoading = false.obs;
  final Rx<Profile?> profile = Rx<Profile?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final p = await _service.getProfile();
      profile.value = p;
    } on ApiException catch (e) {
      errorMessage.value = 'HTTP ${e.statusCode}: ${e.message}';
      print('[ProfileController] ApiException: ${e.statusCode} — ${e.message}');
    } catch (e, st) {
      errorMessage.value = e.toString();
      print('[ProfileController] Unknown error: $e\n$st');
    } finally {
      isLoading.value = false;
      print('[ProfileController] fetchProfile() end');
    }
  }

  Future<void> changeProfilePicture(ImageSource src) async {
    final picked = await _picker.pickImage(source: src, imageQuality: 80);
    if (picked == null) return;

    isLoading.value = true;
    try {
      final file = File(picked.path);
      await _service.updateProfilePicture(file);

      await fetchProfile(); // reload profil terbaru
      Get.back(); // tutup bottom sheet
      Get.snackbar(
        'Sukses',
        'Foto diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal upload foto',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await authService.logout();
    // kalau mau tambahan snackbar:
    Get.snackbar('Success', 'Logout berhasil');
  }
}
