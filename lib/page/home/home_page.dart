import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/history_controller.dart';
import 'package:smart_attendance/controller/home_controller.dart';
import 'package:smart_attendance/controller/profile_controller.dart';
import 'package:smart_attendance/utils/datetime_util.dart';
import 'package:smart_attendance/widget/history_list_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery directly for critical layout components
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive values based on screen dimensions
    final double profilePictureSize = screenWidth * 0.15; // 15% of screen width
    final double cardPadding = screenWidth * 0.02;
    final double iconSize = screenWidth * 0.05;

    final profileController = Get.put(ProfileController());

    // Force ScreenUtil to update when this widget builds
    ScreenUtil.init(
      context,
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          // Siluet atas kiri
          Positioned(
            top: -screenHeight * 0.07,
            left: -screenWidth * 0.12,
            child: Container(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100.withOpacity(0.3),
              ),
            ),
          ),
          // Siluet bawah kanan
          Positioned(
            bottom: -screenHeight * 0.04,
            right: -screenWidth * 0.08,
            child: Container(
              width: screenWidth * 0.4,
              height: screenWidth * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.3),
              ),
            ),
          ),
          // Aksen tambahan
          Positioned(
            bottom: screenHeight * 0.07,
            left: screenWidth * 0.12,
            child: Container(
              width: screenWidth * 0.25,
              height: screenWidth * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100.withOpacity(0.3),
              ),
            ),
          ),
          // Container putih bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.7,
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
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.08),
                    Obx(
                      () => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ScoreCard(
                              title: 'Daily',
                              value: controller.scoreDaily.toString(),
                              icon: Icons.today_rounded,
                              color: Colors.green.shade700,
                              bgColor: Colors.green.shade50,
                            ),
                            _ScoreCard(
                              title: 'Monthly',
                              value: controller.scoreMonthly.toString(),
                              icon: Icons.calendar_month_rounded,
                              color: Colors.blue.shade700,
                              bgColor: Colors.blue.shade50,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: HistoryList(isHome: true),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            top: screenHeight * 0.15,
            child: Obx(() {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenWidth * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          IndonesianDateFormatter.formatTanggalLengkap(
                              DateTime.now()),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      SizedBox(
                        height: screenHeight * 0.1,
                        child: Row(
                          children: [
                            _buildTimeCard(
                              icon: Icons.login,
                              label: controller.inTime,
                              color: Colors.green.shade400,
                              bgColor: const Color(0xFFC7FFCA),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            _buildTimeCard(
                              icon: Icons.pause,
                              label: controller.breakTime,
                              color: Colors.orange.shade400,
                              bgColor: const Color(0xFFFFFFD1),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            _buildTimeCard(
                              icon: Icons.logout,
                              label: controller.outTime,
                              color: Colors.pink.shade400,
                              bgColor: const Color(0xFFFFDEF3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          // Profil di bagian paling atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                // Obx untuk rebuild otomatis saat profile/isLoading/errorMessage berubah
                child: Obx(() {
                  // 1. Loading state
                  if (profileController.isLoading.value) {
                    return SizedBox(
                      height: screenHeight * 0.08,
                      child: Center(
                        child: SizedBox(
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  // 2. Error state
                  if (profileController.errorMessage.isNotEmpty) {
                    return Container(
                      height: screenHeight * 0.08,
                      alignment: Alignment.center,
                      child: Text(
                        profileController.errorMessage.value,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    );
                  }
                  // 3. Data siap
                  final p = profileController.profile.value;
                  final photo = (p?.profilePicture.isNotEmpty == true)
                      ? p!.profilePicture
                      : 'https://icons.veryicon.com/png/o/application/a-group-of-common-linear-icon/walk-1.png';

                  final fullName = p?.fullName ?? '';
                  final company = p?.companyName ?? '';
                  final nip = p?.noEmployee ?? '';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Container(
                          width: profilePictureSize,
                          height: profilePictureSize,
                          color: Colors.grey[200],
                          child: photo.startsWith('data:image/')
                              ? Image.memory(
                                  base64Decode(photo.split(',')[1]),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.broken_image,
                                      size: profilePictureSize * 0.7),
                                )
                              : Image.network(
                                  photo,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.broken_image,
                                      size: profilePictureSize * 0.7),
                                ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            nip,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            company ?? '-',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ScoreCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.1,
                height: screenWidth * 0.1,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: screenWidth * 0.05),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTimeCard({
  required IconData icon,
  required String label,
  required Color color,
  required Color bgColor,
}) {
  return Builder(builder: (context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Card(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: screenWidth * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: screenWidth * 0.04, color: color),
              SizedBox(width: screenWidth * 0.015),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}
