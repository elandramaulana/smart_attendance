import 'package:get/get.dart';
import 'package:smart_attendance/binding/approval_binding.dart';
import 'package:smart_attendance/binding/attendance_binding.dart';
import 'package:smart_attendance/binding/bottom_nav_binding.dart';
import 'package:smart_attendance/binding/correction_binding.dart';
import 'package:smart_attendance/binding/history_binding.dart';
import 'package:smart_attendance/binding/home_binding.dart';
import 'package:smart_attendance/binding/login_binding.dart';
import 'package:smart_attendance/binding/pengajuan_binding.dart';
import 'package:smart_attendance/binding/profile_binding.dart';
import 'package:smart_attendance/controller/splash_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/page/approval/approval_page.dart';
import 'package:smart_attendance/page/attendance/attendance_map_page.dart';
import 'package:smart_attendance/page/auth/login_page.dart';
import 'package:smart_attendance/page/history/correction_page.dart';
import 'package:smart_attendance/page/history/history_detail_page.dart';
import 'package:smart_attendance/page/history/history_page.dart';
import 'package:smart_attendance/page/home/home_page.dart';
import 'package:smart_attendance/page/pengajuan/form_cuti_page.dart';
import 'package:smart_attendance/page/pengajuan/form_izin_page.dart';
import 'package:smart_attendance/page/pengajuan/form_overtime_page.dart';
import 'package:smart_attendance/page/pengajuan/form_sakit_page.dart';
import 'package:smart_attendance/page/pengajuan/history_list_correction.dart';
import 'package:smart_attendance/page/pengajuan/history_list_cuti.dart';
import 'package:smart_attendance/page/pengajuan/history_list_izin.dart';
import 'package:smart_attendance/page/pengajuan/history_list_overtime.dart';
import 'package:smart_attendance/page/pengajuan/history_list_sakit.dart';
import 'package:smart_attendance/page/profile/profile_page.dart';
import 'package:smart_attendance/page/splash/splash_page.dart';
import 'package:smart_attendance/service/auth_service.dart';
import 'package:smart_attendance/widget/bottom_nav_widget.dart';

class AppPages {
  static const initial = AppRoutes.splash;
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        // 1. SharedPreferences sudah ada dari main.dart
        // 2. Supply ApiProvider
        Get.lazyPut<ApiProvider>(() => ApiProvider());
        // 3. Supply AuthService
        Get.lazyPut<AuthService>(() => AuthService(Get.find<ApiProvider>()));
        // 4. Controller
        Get.put(SplashScreenController());
      }),
    ),
    GetPage(
      name: AppRoutes.bottomNav,
      page: () => const BottomNavWidget(),
      binding: BottomNavBinding(), // Gunakan binding bottom navbar
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.historyDetail,
      page: () => const HistoryDetailPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.correction,
      page: () => const CorrectionPage(),
      binding: CorrectionBinding(),
    ),
    GetPage(
      name: AppRoutes.pengajuanCuti,
      page: () => const HistoryListCuti(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.pengajuanLembur,
      page: () => const HistoryListLembur(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.pengajuanSakit,
      page: () => const HistoryListSakit(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.correctionHistory,
      page: () => const HistoryListCorrection(),
      binding: CorrectionBinding(),
    ),
    GetPage(
      name: AppRoutes.pengajuanIzin,
      page: () => const HistoryListIzin(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.formCuti,
      page: () => const FormCutiPage(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.formLembur,
      page: () => const FormOvertimePage(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.formSakit,
      page: () => FormSakitPage(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.formIzin,
      page: () => const FormIzinPage(),
      binding: PengajuanBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.mapAttendance,
      page: () => const AttendanceMapPage(),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: AppRoutes.approval,
      page: () => const ApprovalPage(),
      binding: ApprovalBinding(),
    ),
  ];
}
