import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/profile_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/service/auth_service.dart';

class PengajuanPage extends StatelessWidget {
  const PengajuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double profilePictureSize = screenWidth * 0.15; // 15% of screen width
    final profileController = Get.put(ProfileController());
    return Scaffold(
        body: Stack(
      children: [
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
        // Aksen tambahan
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

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: screenHeight * 0.78,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: FutureBuilder<bool>(
              future: authService.getApprovalStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                final isApproved = snapshot.data ?? false;

                final cards = <Widget>[
                  _buildCompactCard(
                    icon: Icons.beach_access,
                    title: 'Cuti',
                    color: Colors.green[700]!,
                    onTap: () => Get.toNamed(AppRoutes.pengajuanCuti),
                  ),
                  _buildCompactCard(
                    icon: Icons.work,
                    title: 'Lembur',
                    color: Colors.blue[700]!,
                    onTap: () => Get.toNamed(AppRoutes.pengajuanLembur),
                  ),
                  _buildCompactCard(
                    icon: Icons.local_hospital,
                    title: 'Sakit',
                    color: Colors.red[700]!,
                    onTap: () => Get.toNamed(AppRoutes.pengajuanSakit),
                  ),
                  _buildCompactCard(
                    icon: Icons.exit_to_app,
                    title: 'Izin',
                    color: Colors.orange[700]!,
                    onTap: () => Get.toNamed(AppRoutes.pengajuanIzin),
                  ),
                  if (isApproved)
                    _buildCompactCard(
                      icon: Icons.check_circle,
                      title: 'Approval',
                      color: Colors.purple[700]!,
                      onTap: () => Get.toNamed(AppRoutes.approval),
                    ),
                  _buildCompactCard(
                    icon: Icons.edit_calendar,
                    title: 'Koreksi Kehadiran',
                    color: Colors.teal[700]!,
                    onTap: () => Get.toNamed(AppRoutes.correctionHistory),
                  ),
                ];

                return GridView.count(
                  crossAxisCount: 2, // 2 kartu per baris
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cards,
                );
              },
            ),
          ),
        ),

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
                final photo = (p?.logo.isNotEmpty == true)
                    ? p!.logo
                    : 'https://icons.veryicon.com/png/o/application/a-group-of-common-linear-icon/walk-1.png';

                final company = p?.companyName ?? '';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: profilePictureSize,
                      height: profilePictureSize,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        // Tambahkan border jika perlu
                        border: Border.all(
                          color: Colors.grey, // warna border
                          width: 1.0, // ketebalan border
                        ),
                        // Jika kamu mau sudut membulat sedikit, atur BorderRadius
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    SizedBox(width: screenWidth * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
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
    ));
  }
}

Widget _buildCompactCard({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
