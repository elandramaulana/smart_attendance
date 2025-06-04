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

class IzinFormController extends GetxController with MonthYearFilterMixin {
  final _service = SickPermitService();
  var isLoading = false.obs;
  var listIzin = <SickPermitModel>[].obs;

  final formKey = GlobalKey<FormState>();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // Alasan
  final reasonController = TextEditingController();

  // PDF lampiran
  final pickedFile = Rxn<PlatformFile>();
  final fileBase64 = ''.obs;

  @override
  void onInit() {
    super.onInit();
    bindFilter(fetchAll);
    fetchAll(null);
  }

  Future<void> fetchAll(String? month) async {
    try {
      isLoading.value = true;
      final data = await _service.getAbsences(month: month);
      listIzin.assignAll(data.where((e) => e.type == 'Izin Resmi'));
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data izin:\n$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick PDF file
  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      pickedFile.value = file;
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
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Validasi Gagal",
        "Lengkapi semua field",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // prefix data URI
    final lampiranData = 'data:application/pdf;base64,${fileBase64.value}';
    final req = SubmissionRequest.izin(
      tanggalMulai: startDateController.text,
      tanggalSelesai: endDateController.text,
      reason: reasonController.text,
      lampiran: lampiranData,
    );

    try {
      await SubmissionService().submit(req);
      Get.snackbar(
        "Sukses",
        "Pengajuan izin berhasil dikirim",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
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

  final listDummy = <Map<String, String>>[
    {
      "title": "Izin Sakit",
      "dateTime": "1 April 2025 - 08:00 WIB",
      "status": "Disetujui",
      "description": "Pengajuan izin sakit karena demam tinggi dan flu."
    },
    {
      "title": "Izin Kepentingan Pribadi",
      "dateTime": "3 April 2025 - 09:00 WIB",
      "status": "Pending",
      "description": "Izin untuk urusan keluarga yang mendesak."
    },
    {
      "title": "Izin Menghadiri Seminar",
      "dateTime": "5 April 2025 - 07:30 WIB",
      "status": "Disetujui",
      "description": "Izin untuk menghadiri seminar peningkatan kompetensi."
    },
    {
      "title": "Izin Kegiatan Sosial",
      "dateTime": "10 April 2025 - 10:00 WIB",
      "status": "Ditolak",
      "description":
          "Pengajuan izin untuk mengikuti kegiatan sosial ditolak karena jadwal kerja."
    },
    {
      "title": "Izin Urusan Administratif",
      "dateTime": "15 April 2025 - 08:30 WIB",
      "status": "Disetujui",
      "description":
          "Izin untuk mengurus keperluan administrasi di instansi pemerintah."
    },
    {
      "title": "Izin Pemberitahuan Dini",
      "dateTime": "20 April 2025 - 11:00 WIB",
      "status": "Pending",
      "description": "Izin untuk tidak masuk kerja karena keperluan mendadak."
    },
    {
      "title": "Izin Keluar Kantor",
      "dateTime": "25 April 2025 - 14:00 WIB",
      "status": "Disetujui",
      "description": "Izin keluar kantor untuk keperluan meeting dengan klien."
    },
  ];
}
