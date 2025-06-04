import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:smart_attendance/controller/buttom_nav_controller.dart';
import 'package:smart_attendance/page/approval/approval_page.dart';
import 'package:smart_attendance/page/attendance/attendance_map_page.dart';
import 'package:smart_attendance/page/history/history_page.dart';
import 'package:smart_attendance/page/home/home_page.dart';
import 'package:smart_attendance/page/profile/profile_list.dart';
import 'package:smart_attendance/page/pengajuan/pengajuan_page.dart';

class BottomNavWidget extends GetView<BottomNavController> {
  const BottomNavWidget({super.key});

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const HistoryPage(),
      const AttendanceMapPage(),
      const PengajuanPage(),
      const ProfileList(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.blueGrey,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.history),
        title: "History",
        activeColorPrimary: Colors.blueGrey,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Container(
          width: 40.0, // pastikan > 0
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.blueGrey, // background bulat
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.location_on, // ikon lokasi
              color: Colors.white, // putih
              size: 24.0, // ukuran ikon
            ),
          ),
        ),
        // kosongkan title agar tidak mempengaruhi layout:
        title: null,
        // biar container/ikon mu sendiri yang terlihat:
        activeColorPrimary: Colors.transparent,
        inactiveColorPrimary: Colors.transparent,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.description),
        title: "Pengajuan",
        activeColorPrimary: Colors.blueGrey,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: "Profil",
        activeColorPrimary: Colors.blueGrey,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final atHome = controller.currentIndex.value == 0;
      return PopScope(
        // hanya izinkan pop (exit) jika sudah di Home
        canPop: atHome,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            // kalau didPop false artinya kita belum di Home
            controller.navController.jumpToTab(0);
          }
        },
        child: PersistentTabView(
          context,
          controller: controller.navController,
          screens: _buildScreens(),
          items: _navBarsItems(),
          onItemSelected: controller.onTabSelected,

          // **disable** builtin back handling:
          handleAndroidBackButtonPress: false,

          // sisanya tetap
          navBarHeight: 60.0,
          confineToSafeArea: true,
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          navBarStyle: NavBarStyle.style16,
        ),
      );
    });
  }
}
