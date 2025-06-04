import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/overtime_list_model.dart';
import 'package:smart_attendance/model/overtime_model.dart';
import 'package:smart_attendance/service/overtime_service.dart';
import 'package:smart_attendance/utils/filter_mixin.dart';

class OvertimeController extends GetxController with MonthYearFilterMixin {
  final OvertimeService _service = OvertimeService();
  var isLoading = false.obs;
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

  @override
  void onInit() {
    super.onInit();
    bindFilter(fetchAll);
    fetchAll(null);
  }

  Future<void> fetchAll(String? month) async {
    try {
      isLoading.value = true;
      final data = await _service.getOvertimes(month: month);
      listOvertime.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data lembur:\n$e');
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
  Future pickDateStart(BuildContext ctx) async {
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

  Future pickDateEnd(BuildContext ctx) async {
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
  Future pickTimeStart(BuildContext ctx) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: timeStart.value ?? TimeOfDay.now(),
    );
    if (picked != null) timeStart.value = picked;
  }

  Future pickTimeEnd(BuildContext ctx) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: timeEnd.value ?? TimeOfDay.now(),
    );
    if (picked != null) timeEnd.value = picked;
  }

  // SUBMIT
  Future submitForm() async {
    // validasi semua field
    if (dateStart.value == null ||
        dateEnd.value == null ||
        timeStart.value == null ||
        timeEnd.value == null ||
        descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Lengkapi semua field terlebih dahulu');
      return;
    }

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
      // Snackbar sukses
      Get.snackbar(
        'Success',
        'Pengajuan lembur berhasil',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Arahkan kembali ke bottomNav
      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim pengajuan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  final listDummy = <Map<String, String>>[
    {
      "title": "Lembur Proyek A",
      "dateTime": "1 April 2025 - 18:00 WIB",
      "status": "Disetujui",
      "description": "Lembur untuk menyelesaikan deadline Proyek A."
    },
    {
      "title": "Lembur Persiapan Meeting",
      "dateTime": "3 April 2025 - 19:00 WIB",
      "status": "Pending",
      "description": "Lembur mempersiapkan materi untuk meeting klien."
    },
    {
      "title": "Lembur Update Sistem",
      "dateTime": "5 April 2025 - 20:00 WIB",
      "status": "Disetujui",
      "description":
          "Lembur untuk melakukan update sistem dan maintenance server."
    },
    {
      "title": "Lembur Evaluasi Kinerja",
      "dateTime": "10 April 2025 - 21:00 WIB",
      "status": "Ditolak",
      "description":
          "Pengajuan lembur untuk evaluasi kinerja, namun pengajuan ditolak."
    },
    {
      "title": "Lembur Kick-Off Proyek",
      "dateTime": "15 April 2025 - 18:30 WIB",
      "status": "Disetujui",
      "description": "Lembur sebagai persiapan kick-off proyek baru."
    },
    {
      "title": "Lembur Penyelesaian Dokumen",
      "dateTime": "20 April 2025 - 20:30 WIB",
      "status": "Pending",
      "description":
          "Pengajuan lembur untuk menyelesaikan dokumen laporan akhir."
    },
    {
      "title": "Lembur Darurat",
      "dateTime": "25 April 2025 - 22:00 WIB",
      "status": "Disetujui",
      "description": "Lembur mendadak karena adanya kendala operasional."
    },
  ];
}
