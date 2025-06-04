import 'package:get/get.dart';
import 'package:smart_attendance/controller/login_controller.dart';
import 'package:smart_attendance/controller/profile_controller.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/service/auth_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiProvider>(() => ApiProvider());
    Get.lazyPut<AuthService>(() => AuthService(Get.find<ApiProvider>()));
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<ApiProvider>()),
    );
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
