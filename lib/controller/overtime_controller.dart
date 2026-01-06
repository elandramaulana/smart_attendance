import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/overtime_list_model.dart';
import 'package:smart_attendance/model/overtime_model.dart';
import 'package:smart_attendance/service/overtime_service.dart';
import 'package:smart_attendance/utils/filter_mixin.dart';

class OvertimeController extends GetxController with MonthYearFilterMixin {
  final OvertimeService _service = OvertimeService();

  // ✅ PERBAIKAN 1: Set initial loading ke true
  var isLoading = true.obs;
  var listOvertime = <OvertimeListModel>[].obs;

  // Controllers untuk TextFormField tanggal
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // Rx untuk menyimpan object DateTime / TimeOfDay
  final dateStart = Rxn<DateTime>();
  final dateEnd = Rxn<DateTime>();
  final timeStart = Rxn<TimeOfDay>();
  final timeEnd = Rxn<TimeOfDay>();

  // Controller untuk deskripsi
  final descriptionController = TextEditingController();

  // ✅ PERBAIKAN 2: Tambahkan flag untuk track initialization
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    bindFilter(fetchAll);
    // ✅ PERBAIKAN 3: Wrap fetchAll dalam try-catch
    _initializeData();
  }

  // ✅ PERBAIKAN 4: Pisahkan initialization logic
  Future<void> _initializeData() async {
    try {
      await fetchAll(null);
      isInitialized.value = true;
    } catch (e) {
      debugPrint('Error initializing overtime data: $e');
      isInitialized.value = true; // Set true meski error agar UI tidak stuck
    }
  }

  Future<void> fetchAll(String? month) async {
    try {
      isLoading.value = true;
      final data = await _service.getOvertimes(month: month);

      // ✅ PERBAIKAN 5: Tambahkan null check dan defensive copying
      if (data != null) {
        listOvertime.assignAll(data);
      } else {
        listOvertime.clear();
      }
    } catch (e) {
      debugPrint('Error fetching overtime data: $e');
      // ✅ PERBAIKAN 6: Hanya tampilkan snackbar jika sudah initialized
      if (isInitialized.value) {
        Get.snackbar(
          'Error',
          'Gagal mengambil data lembur',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 2),
        );
      }
      // Clear list jika error
      listOvertime.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  // PICK DATE
  Future<void> pickDateStart(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: dateStart.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateStart.value = picked;
      startDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> pickDateEnd(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: dateEnd.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateEnd.value = picked;
      endDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  // PICK TIME
  Future<void> pickTimeStart(BuildContext ctx) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: timeStart.value ?? TimeOfDay.now(),
    );
    if (picked != null) timeStart.value = picked;
  }

  Future<void> pickTimeEnd(BuildContext ctx) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: timeEnd.value ?? TimeOfDay.now(),
    );
    if (picked != null) timeEnd.value = picked;
  }

  // ✅ PERBAIKAN 7: Tambahkan validation helper
  bool _validateForm() {
    if (dateStart.value == null) {
      Get.snackbar(
        'Validasi',
        'Pilih tanggal mulai terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    if (dateEnd.value == null) {
      Get.snackbar(
        'Validasi',
        'Pilih tanggal selesai terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    if (timeStart.value == null) {
      Get.snackbar(
        'Validasi',
        'Pilih waktu mulai terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    if (timeEnd.value == null) {
      Get.snackbar(
        'Validasi',
        'Pilih waktu selesai terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Validasi',
        'Masukkan deskripsi lembur',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    // ✅ PERBAIKAN 8: Validasi logika tanggal
    if (dateEnd.value!.isBefore(dateStart.value!)) {
      Get.snackbar(
        'Validasi',
        'Tanggal selesai tidak boleh lebih awal dari tanggal mulai',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    return true;
  }

  // SUBMIT
  Future<void> submitForm() async {
    // ✅ PERBAIKAN 9: Gunakan helper validation
    if (!_validateForm()) return;

    final model = Overtime(
      dateStart: dateStart.value!.toIso8601String().split('T').first,
      timeStart: formatTime(timeStart.value!),
      dateEnd: dateEnd.value!.toIso8601String().split('T').first,
      timeEnd: formatTime(timeEnd.value!),
      descriptions: descriptionController.text.trim(),
    );

    try {
      isLoading.value = true;
      await _service.submitOvertime(model);

      // ✅ PERBAIKAN 10: Clear form setelah sukses
      _clearForm();

      // Snackbar sukses
      Get.snackbar(
        'Berhasil',
        'Pengajuan lembur berhasil dikirim',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Arahkan kembali ke bottomNav
      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      debugPrint('Error submitting overtime: $e');
      Get.snackbar(
        'Gagal',
        'Gagal mengirim pengajuan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ PERBAIKAN 11: Helper untuk clear form
  void _clearForm() {
    startDateController.clear();
    endDateController.clear();
    descriptionController.clear();
    dateStart.value = null;
    dateEnd.value = null;
    timeStart.value = null;
    timeEnd.value = null;
  }

  // ✅ PERBAIKAN 12: Public method untuk manual clear form
  void clearForm() {
    _clearForm();
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
