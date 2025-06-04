import 'package:get/get.dart';
import 'package:smart_attendance/controller/login_controller.dart';
import 'package:smart_attendance/core/base_provider.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan ApiProvider jika belum
    Get.lazyPut<ApiProvider>(() => ApiProvider());

    // Daftarkan LoginController dengan injeksi ApiProvider
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<ApiProvider>()),
    );
  }
}
