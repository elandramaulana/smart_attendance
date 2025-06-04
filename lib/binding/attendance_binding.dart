// bottom_nav_binding.dart
import 'package:get/get.dart';
import 'package:smart_attendance/controller/map_attendance_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapAttendanceController>(() => MapAttendanceController());
  }
}
