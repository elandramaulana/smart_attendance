import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/sick_permit_model.dart';
import 'package:smart_attendance/model/submission_request.dart';
import 'package:smart_attendance/service/sick_permit_service.dart';
import 'package:smart_attendance/service/submission_service.dart';
import 'package:smart_attendance/utils/filter_mixin.dart';

class SakitFormController extends GetxController with MonthYearFilterMixin {
  final _service = SickPermitService();
  var isLoading = false.obs;
  var listSakit = <SickPermitModel>[].obs;

  final formKey = GlobalKey<FormState>();

  // Form controllers
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final reasonController = TextEditingController();

  // File picker
  final pickedFile = Rxn<PlatformFile>();
  final fileBase64 = ''.obs;

  // Jenis sakit options
  final jenisSakit = ['dengan_surat', 'tanpa_surat'];
  final selectedJenis = ''.obs;

  // Loading state
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    bindFilter(fetchAll);
    fetchAll(null);

    // Set default jenis sakit ke "tanpa_surat"
    selectedJenis.value = jenisSakit[1];
  }

  Future<void> fetchAll(String? month) async {
    try {
      isLoading.value = true;
      final sakitData = await _service.getAbsences(month: month);
      listSakit.assignAll(sakitData);
      debugPrint("📊 Fetched ${sakitData.length} sakit records");
    } catch (e) {
      if (e.toString().contains('404') ||
          e.toString().contains('Tidak ada data')) {
        listSakit.clear();
        Get.snackbar(
          "Info",
          "Tidak ada data sakit untuk periode yang dipilih",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Gagal mengambil data sakit: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear filter & reload all
  void clearFilter() {
    selectedMonth.value = null;
    selectedYear.value = null;
    fetchAll(null);
  }

  /// Pick PDF file
  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        pickedFile.value = file;

        // Convert to base64
        final bytes = file.bytes!;
        fileBase64.value = base64Encode(bytes);
      }
    } catch (e) {
      debugPrint("❌ Error picking PDF: $e");
      Get.snackbar(
        "Error",
        "Gagal memilih file: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick date
  Future<void> pickDate(
      BuildContext context, TextEditingController targetCtrl) async {
    final DateTime? dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (dt != null) {
      final formatted =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      targetCtrl.text = formatted;
    }
  }

  /// Submit form sakit
  Future<void> submitForm() async {
    // Prevent double submission
    if (isSubmitting.value) {
      return;
    }

    // 1. Validasi form fields
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Validasi Gagal",
        "Lengkapi semua field yang diperlukan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Validasi jenis sakit harus dipilih
    if (selectedJenis.value.isEmpty) {
      Get.snackbar(
        "Validasi Gagal",
        "Pilih jenis sakit (dengan/tanpa surat dokter)",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 3. Jika pilih "dengan_surat", wajib upload PDF
    if (selectedJenis.value == 'dengan_surat' && pickedFile.value == null) {
      Get.snackbar(
        "Validasi Gagal",
        "Anda harus mengunggah surat dokter (PDF)",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Set loading
    isSubmitting.value = true;

    // 4. Siapkan lampiran (base64 string, tanpa prefix)
    String? lampiranBase64;
    if (selectedJenis.value == 'dengan_surat' && fileBase64.value.isNotEmpty) {
      lampiranBase64 = fileBase64.value;
    } else {
      lampiranBase64 = null;
    }

    // 5. Buat request object
    final req = SubmissionRequest.sakit(
      tanggalMulai: startDateController.text,
      tanggalSelesai: endDateController.text,
      reason: reasonController.text,
      lampiran: lampiranBase64,
      jenisSakit: selectedJenis.value,
    );

    final formData = req.toFormData();
    formData.forEach((key, value) {
      if (key == 'lampiran') {
        debugPrint(
            "  ✓ $key: [base64 string, ${value.toString().length} chars]");
      } else {
        debugPrint("  ✓ $key: $value");
      }
    });
    // 6. Submit ke API
    try {
      debugPrint("🌐 Sending to API...");
      await SubmissionService().submitSakit(req);

      debugPrint("✅ SUBMISSION SUCCESS!");

      Get.snackbar(
        "Sukses",
        "Pengajuan sakit berhasil dikirim",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form
      _clearForm();

      // Navigate back
      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSubmitting.value = false;
      debugPrint("=== 🏁 SUBMISSION ENDED ===\n");
    }
  }

  /// Clear form after successful submission
  void _clearForm() {
    startDateController.clear();
    endDateController.clear();
    reasonController.clear();
    pickedFile.value = null;
    fileBase64.value = '';
    selectedJenis.value = jenisSakit[1]; // Reset to tanpa_surat
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
