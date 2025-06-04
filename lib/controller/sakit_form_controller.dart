import 'dart:convert';
import 'dart:io';
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

  // Dua tanggal: mulai & selesai
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // Alasan
  final reasonController = TextEditingController();

  // Opsi “dengan/tanpa surat dokter”
  final isWithDoctorNote = false.obs;

  // PDF lampiran (jika “dengan surat dokter”)
  final pickedFile = Rxn<PlatformFile>();
  final fileBase64 = ''.obs;

  @override
  void onInit() {
    super.onInit();
    bindFilter(fetchAll);
    fetchAll(null);
  }

  Future<void> fetchAll(String? month) async {
    debugPrint("Fetching sakit data for month: $month");
    try {
      isLoading.value = true;
      final data = await _service.getAbsences(month: month);
      final sakitData = data
          .where((e) =>
              e.type == 'Sakit Surat Dokter' || e.type == 'Sakit tanpa Surat')
          .toList();
      listSakit.assignAll(sakitData);
      debugPrint("Fetched ${sakitData.length} sakit records");
    } catch (e, stack) {
      debugPrint("Error fetching sakit data: $e");
      debugPrint("Stack trace:\n$stack");
      Get.snackbar('Error', 'Gagal mengambil data sakit:\n$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick PDF file (hanya jika user memilih “dengan surat dokter”)
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

  Future<void> pickDate(
      BuildContext context, TextEditingController targetCtrl) async {
    final DateTime? dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (dt != null) {
      targetCtrl.text =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> submitForm() async {
    // 1. Validasi form text (tanggal & alasan)
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

    // 2. Jika user memilih “dengan surat dokter”, pastikan ada file PDF
    if (isWithDoctorNote.value && pickedFile.value == null) {
      Get.snackbar(
        "Validasi Gagal",
        "Anda harus mengunggah surat dokter.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 3. Siapkan data lampiran (hanya jika withDoctorNote == true)
    String? lampiranDataUri;
    if (isWithDoctorNote.value) {
      // Prefix data URI agar backend tahu ini base64 PDF
      lampiranDataUri = 'data:application/pdf;base64,${fileBase64.value}';
    } else {
      // Tanpa surat dokter → tidak menyertakan lampiran
      lampiranDataUri = null;
    }

    // 4. Buat objek request dengan atau tanpa lampiran
    final req = SubmissionRequest.sakit(
      tanggalMulai: startDateController.text,
      tanggalSelesai: endDateController.text,
      reason: reasonController.text,
      lampiran: lampiranDataUri, // null jika user pilih tanpa surat
      withDoctorNote: isWithDoctorNote.value,
    );

    try {
      await SubmissionService().submit(req);
      Get.snackbar(
        "Sukses",
        "Pengajuan sakit berhasil dikirim",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Setelah submit, kembali ke bottomNav (atau halaman lain)
      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
