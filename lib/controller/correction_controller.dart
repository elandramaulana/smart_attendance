// lib/controller/correction_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/correctionr_req_model.dart';
import 'package:smart_attendance/model/history_model.dart';
import 'package:smart_attendance/service/correction_service.dart';

class CorrectionController extends GetxController {
  // Service untuk submit koreksi
  final CorrectionService _service = Get.put(CorrectionService());

  // Data history yang akan dikoreksi
  late final History history;

  // Tanggal absensi yang diambil dari history
  late final DateTime selectedDate;

  // State form
  var selectedAbsenceType = ''.obs; // 'in', 'break', 'out'
  var selectedTime = Rx<TimeOfDay?>(null);
  var reason = ''.obs;
  var isSubmitting = false.obs;

  // Opsi jenis koreksi
  final List<String> absenceTypes = ['in', 'break', 'out'];

  @override
  void onInit() {
    super.onInit();
    // Ambil History dari argument dan simpan
    history = Get.arguments as History;
    selectedDate = history.date;
  }

  /// Pilih jenis koreksi ('in','break','out')
  void selectAbsenceType(String type) {
    selectedAbsenceType.value = type;
  }

  /// Pilih jam koreksi
  void selectTime(TimeOfDay t) {
    selectedTime.value = t;
  }

  Future<bool> submitCorrection() async {
    if (selectedAbsenceType.value.isEmpty) {
      Get.snackbar('Error', 'Pilih jenis koreksi terlebih dahulu',
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (selectedTime.value == null) {
      Get.snackbar('Error', 'Pilih jam koreksi terlebih dahulu',
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (reason.value.trim().isEmpty) {
      Get.snackbar('Error', 'Masukkan alasan koreksi',
          snackPosition: SnackPosition.TOP);
      return false;
    }

    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getInt('user_id') ?? 0;

      final t = selectedTime.value!;
      final correctionTime = '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}:00';

      final req = CorrectionRequest(
        userId: uid,
        correctionType: selectedAbsenceType.value,
        date: selectedDate,
        correctionTime: correctionTime,
        reason: reason.value.trim(),
      );

      final resp = await _service.submitCorrection(req);
      if (resp.success) {
        Get.snackbar(
          'Success',
          'Koreksi Berhasil diajujan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          resp.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', "Anda sudah mengajukan koreksi untuk jenis ini",
          snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
