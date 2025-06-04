import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/widget/profile_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // === 1. Background dan dekorasi lingkaran ===
          Container(
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100.withOpacity(0.3),
              ),
            ),
          ),
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

          // === 2. Container putih di bawah (fixed height 85%) ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.85, // batasi tinggi white container
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400.withOpacity(0.6),
                    offset: const Offset(0, -4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              // Di sinilah kita letakkan ProfileCard (yang nanti memuat Stack avatar + ScrollView info)
              child: ProfileCard(),
            ),
          ),

          // === 3. Tombol Back ===
          Positioned(
            top: 10.h,
            left: 16.w,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
