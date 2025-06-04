import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/model/history_model.dart';
import 'package:smart_attendance/service/history_service.dart';

class HistoryController extends GetxController {
  final HistoryService _historyService = Get.put(HistoryService());

  var histories = <History>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Filter
  var isFilterActive = false.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    // Default: ambil dari tgl 1 bulan ini sampai hari ini
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    fetchHistory(startDate: firstOfMonth, endDate: now);
  }

  String get monthName {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[selectedMonth.value - 1];
  }

  void filterByMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    isFilterActive.value = true;

    final first = DateTime(year, month, 1);
    final last =
        month < 12 ? DateTime(year, month + 1, 0) : DateTime(year + 1, 1, 0);

    fetchHistory(startDate: first, endDate: last);
  }

  void resetFilter() {
    isFilterActive.value = false;
    final now = DateTime.now();
    selectedMonth.value = now.month;
    selectedYear.value = now.year;
    fetchHistory(startDate: DateTime(now.year, now.month, 1), endDate: now);
  }

  Future<void> fetchHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getInt('user_id') ?? 0;

      final result = await _historyService.getHistory(
        userId: uid,
        startDate: startDate,
        endDate: endDate,
      );
      histories.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }
}
