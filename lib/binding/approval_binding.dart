import 'package:get/get.dart';
import 'package:smart_attendance/controller/approval_controller.dart';

class ApprovalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApprovalController>(() => ApprovalController());
  }
}
