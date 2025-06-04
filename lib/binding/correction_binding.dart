import 'package:get/get.dart';
import 'package:smart_attendance/controller/correction_controller.dart';
import 'package:smart_attendance/controller/correction_list_controller.dart';
import 'package:smart_attendance/service/correction_service.dart';

class CorrectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CorrectionService>(() => CorrectionService());
    Get.lazyPut<CorrectionListController>(() => CorrectionListController());
    Get.lazyPut<CorrectionController>(() => CorrectionController());
  }
}
