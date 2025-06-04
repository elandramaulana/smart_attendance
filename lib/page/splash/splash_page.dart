import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/splash_controller.dart';
import 'package:smart_attendance/core/app_config.dart';

class SplashScreen extends GetView<SplashScreenController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient agar selaras dengan LoginPage
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF3F0), Color(0xFFE3F2FD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Siluet atas kiri
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.shade100.withOpacity(0.3),
              ),
            ),
          ),
          // Siluet bawah kanan
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.3),
              ),
            ),
          ),
          // Tambahan siluet sebagai aksen
          Positioned(
            bottom: 50,
            left: 50,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100.withOpacity(0.3),
              ),
            ),
          ),
          // Konten utama splash screen
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/Smartend.png',
                  width: 150.w,
                  height: 150.h,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Selamat Datang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    'Aplikasi Smart Attendance\nAbsensi Digital Koperasi Karyalin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Version text di bottom center
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Text(
              'Version ${AppConfig.version} (Beta)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
