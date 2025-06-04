import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/app_pages.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/service/auth_service.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  await FMTCObjectBoxBackend().initialise();
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Get.putAsync<SharedPreferences>(() => SharedPreferences.getInstance());

  final apiProvider = ApiProvider();
  final authService = AuthService(apiProvider);

  Get.put<ApiProvider>(apiProvider);
  Get.put<AuthService>(authService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Smart Attendance',
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: Theme.of(context).textTheme.apply(
                  fontSizeFactor: 1.0,
                ),
          ),
          builder: (context, widget) {
            ScreenUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
