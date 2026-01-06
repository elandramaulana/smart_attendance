import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/model/attendance_today_model.dart';
import 'package:smart_attendance/service/home_service.dart';
import 'package:smart_attendance/controller/history_controller.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final HomeService _service;
  final HistoryController historyController;

  var todayAtt = Rxn<AttendanceTodayModel>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  HomeController({
    HomeService? service,
  })  : _service = service ?? HomeService(),
        historyController = Get.find<HistoryController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    fetchTodayAttendance();

    final now = DateTime.now();
    historyController.fetchHistory(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Ketika app kembali ke foreground → panggil ulang fetch
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchTodayAttendance();
    }
  }

  Future<void> fetchTodayAttendance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getTodayAttendance();
      todayAtt.value = data;
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  String _formatShortTime(String? fullTime) {
    if (fullTime == null || fullTime.isEmpty) return '--:--';
    final parts = fullTime.split(':');
    if (parts.length < 2) return '--:--';
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String get inTime => _formatShortTime(todayAtt.value?.inTime);
  String get outTime => _formatShortTime(todayAtt.value?.outTime);
  String get scoreDaily => todayAtt.value?.dailyScore ?? '-';
  String get scoreMonthly => todayAtt.value?.monthlyScore ?? '-';
}
