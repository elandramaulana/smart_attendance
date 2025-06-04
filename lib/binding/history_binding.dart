import 'package:get/get.dart';
import 'package:smart_attendance/controller/history_controller.dart';
import 'package:smart_attendance/controller/home_controller.dart';
import 'package:smart_attendance/service/history_service.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    // Binding untuk service dan controller
    Get.lazyPut<HistoryService>(() => HistoryService());
    Get.lazyPut<HistoryController>(() => HistoryController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
