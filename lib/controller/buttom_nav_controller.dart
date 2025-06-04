// bottom_nav_controller.dart
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BottomNavController extends GetxController {
  late final PersistentTabController navController;

  /// Observable index to track tab changes
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    navController = PersistentTabController(initialIndex: 0)
      ..addListener(() {
        currentIndex.value = navController.index;
      });
  }

  /// Dipanggil oleh PersistentTabView.onItemSelected
  void onTabSelected(int index) {
    // pindah tab
    navController.jumpToTab(index);
    // currentIndex akan otomatis ter-update oleh listener
  }

  @override
  void onClose() {
    navController.removeListener(() {});
    super.onClose();
  }
}
