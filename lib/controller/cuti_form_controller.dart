import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/cuti_model.dart';
import 'package:smart_attendance/model/submission_request.dart';
import 'package:smart_attendance/service/cuti_service.dart';
import 'package:smart_attendance/service/submission_service.dart';

class CutiFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final jenisLeaveController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();

  final _service = SubmissionService();

  final _cutiService = CutiService();
  var isLoading = false.obs;
  var listCuti = <CutiModel>[].obs;

  final List<String> months = DateFormat.MMMM().dateSymbols.MONTHS;
  final List<int> years = List.generate(5, (i) => DateTime.now().year - i);
  var selectedMonth = RxnString();
  var selectedYear = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchCuti();
    everAll([selectedMonth, selectedYear], (_) => applyFilter());
  }

  Future<void> fetchCuti({String? month}) async {
    try {
      isLoading.value = true;
      final data = await _cutiService.getCuti(month: month);
      listCuti.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data cuti:\n$e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Panggil ini setelah user pilih bulan+tahun
  void applyFilter() {
    final m = selectedMonth.value;
    final y = selectedYear.value;
    // kalau salah satu null → fetch semua
    if (m == null || y == null) {
      fetchCuti();
      return;
    }
    final idx = months.indexOf(m) + 1; // Januari → 1
    final mm = idx.toString().padLeft(2, '0');
    final yyyy = y.toString();
    fetchCuti(month: '$yyyy-$mm');
  }

  /// Clear filter & reload all
  void clearFilter() {
    selectedMonth.value = null;
    selectedYear.value = null;
    fetchCuti();
  }

  final jenisLeaveOptions = [
    'cuti tahunan',
    'cuti melahirkan',
    'cuti alasan penting',
  ];

  final selectedJenisLeave = ''.obs;

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
    if (!formKey.currentState!.validate()) return;

    final req = SubmissionRequest.leave(
        tanggalMulai: startDateController.text,
        tanggalSelesai: endDateController.text,
        reason: descriptionController.text,
        jenisLeave: selectedJenisLeave.value);

    try {
      await _service.submit(req);
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
    }
  }

  @override
  void onClose() {
    jenisLeaveController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
