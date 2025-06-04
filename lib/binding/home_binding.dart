import 'package:get/get.dart';
import 'package:smart_attendance/controller/history_controller.dart';
import 'package:smart_attendance/controller/home_controller.dart';
import 'package:smart_attendance/controller/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(() => HistoryController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
