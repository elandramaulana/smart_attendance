import 'package:get/get.dart';
import 'package:smart_attendance/controller/cuti_form_controller.dart';
import 'package:smart_attendance/controller/izin_form_controller.dart';
import 'package:smart_attendance/controller/overtime_controller.dart';
import 'package:smart_attendance/controller/sakit_form_controller.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/service/auth_service.dart';

class PengajuanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(Get.find<ApiProvider>()));
    Get.lazyPut<CutiFormController>(() => CutiFormController());
    Get.lazyPut<OvertimeController>(() => OvertimeController());
    // Get.lazyPut<IzinFormController>(() => IzinFormController());
    Get.lazyPut<SakitFormController>(() => SakitFormController());
  }
}
