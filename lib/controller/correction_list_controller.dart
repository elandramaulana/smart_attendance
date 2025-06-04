// lib/controller/correction_controller.dart

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance/model/correction_history_model.dart';
import 'package:smart_attendance/service/correction_service.dart';

class CorrectionListController extends GetxController {
  final _service = CorrectionService();
  final List<String> months = DateFormat.MMMM().dateSymbols.MONTHS;
  final List<int> years = List.generate(5, (i) => DateTime.now().year - i);
  var selectedMonth = RxnString();
  var selectedYear = RxnInt();

  var listCorrection = <CorrectionListModel>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCorrection();
    everAll([selectedMonth, selectedYear], (_) => applyFilter());
  }

  Future<void> fetchCorrection({String? month}) async {
    try {
      isLoading.value = true;
      final data = await _service.getCorrection(month: month);
      listCorrection.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data koreksi:\n$e",
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
      fetchCorrection();
      return;
    }
    final idx = months.indexOf(m) + 1; // Januari → 1
    final mm = idx.toString().padLeft(2, '0');
    final yyyy = y.toString();
    fetchCorrection(month: '$yyyy-$mm');
  }
}
