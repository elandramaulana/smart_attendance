import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/cuti_model.dart';
import 'package:smart_attendance/model/submission_request.dart';
import 'package:smart_attendance/service/cuti_service.dart';
import 'package:smart_attendance/service/submission_service.dart';
import 'package:smart_attendance/utils/filter_mixin.dart';

class CutiFormController extends GetxController with MonthYearFilterMixin {
  final formKey = GlobalKey<FormState>();

  final jenisLeaveController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();

  final _service = SubmissionService();
  final _cutiService = CutiService();

  var isLoading = false.obs;
  var listCuti = <CutiModel>[].obs;

  // PDF lampiran (jika “dengan surat dokter”)
  final pickedFile = Rxn<PlatformFile>();
  final fileBase64 = ''.obs;

  final isWithLampiran = false.obs;

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    bindFilter(fetchCuti);
    fetchCuti(null);
  }

  Future<void> fetchCuti(String? month) async {
    try {
      isLoading.value = true;

      final data = await _cutiService.getCuti(month: month);
      listCuti.assignAll(data);
    } catch (e) {
      if (e.toString().contains('404') ||
          e.toString().contains('Tidak ada data')) {
        listCuti.clear();
        Get.snackbar(
          "Info",
          "Tidak ada data izin untuk periode yang dipilih",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Gagal mengambil data izin:\n$e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      // PENTING: Pastikan loading selalu di-set false
      isLoading.value = false;
    }
  }

  /// Clear filter & reload all
  void clearFilter() {
    selectedMonth.value = null;
    selectedYear.value = null;
    fetchCuti(null);
  }

  final jenisLeaveOptions = [
    'cuti_tahunan',
    'cuti_melahirkan',
    'cuti_anak_khitan',
    'cuti_nikah',
    'cuti_pernikahan_anak',
    'cuti_kematian',
    'cuti_izin_pribadi',
  ];

  final selectedJenisLeave = ''.obs;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      pickedFile.value = file;

      // Simpan base64 agar bisa dikirim dalam request
      final bytes = file.bytes!;
      fileBase64.value = base64Encode(bytes);
    }
  }

  /// Picker tanggal, untuk controller mana saja
  Future<void> pickDate(
      BuildContext context, TextEditingController targetCtrl) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blueGrey,
            onPrimary: Colors.white,
            onSurface: Colors.blueGrey,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      targetCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> submitForm() async {
    // Cek apakah sedang dalam proses submit
    if (isSubmitting.value) return;

    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Validasi Gagal",
        "Lengkapi semua field",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (isWithLampiran.value && pickedFile.value == null) {
      Get.snackbar(
        "Validasi Gagal",
        "Anda harus mengunggah lampiran.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi: jika dengan lampiran, pastikan file sudah dipilih
    if (isWithLampiran.value &&
        (pickedFile.value == null || fileBase64.value.isEmpty)) {
      Get.snackbar(
        "Peringatan",
        "Silakan pilih file PDF lampiran",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Set loading state ke true
    isSubmitting.value = true;

    // Siapkan data lampiran (hanya jika withLampiran == true)
    String? lampiranDataUri;
    if (isWithLampiran.value && fileBase64.value.isNotEmpty) {
      lampiranDataUri = 'data:application/pdf;base64,${fileBase64.value}';
    }

    final req = SubmissionRequest.leave(
      tanggalMulai: startDateController.text,
      tanggalSelesai: endDateController.text,
      reason: descriptionController.text,
      jenisLeave: selectedJenisLeave.value,
      lampiran: lampiranDataUri,
    );

    try {
      await _service.submitCuti(req);
      Get.snackbar(
        "Sukses",
        "Pengajuan cuti berhasil dikirim",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengirim pengajuan: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      // Reset loading state
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    jenisLeaveController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    isSubmitting.value = false;
    super.onClose();
  }
}
