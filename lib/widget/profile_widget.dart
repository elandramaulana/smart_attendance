import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/profile_controller.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/profile_controller.dart';

class ProfileCard extends GetView<ProfileController> {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller di‐instantiate
    Get.put(ProfileController());

    return Obx(() {
      final p = controller.profile.value;

      // Fallback jika belum ada data
      final photoUrl = (p?.profilePicture.isNotEmpty == true)
          ? p!.profilePicture
          : 'https://icons.veryicon.com/png/o/application/a-group-of-common-linear-icon/walk-1.png';
      final nip = p?.noEmployee ?? '';
      final name = p?.fullName ?? '';
      final position = p?.positionName ?? '';
      final companyName = p?.companyName ?? '';
      final location = p?.address ?? '';
      final companyType = p?.companyType ?? '';
      final divisionName = p?.divisionName ?? '';

      // LayoutBuilder → agar kita tahu batas tinggi di parent (container putih)
      return LayoutBuilder(builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none, // biar avatar bisa “menjorok” ke atas
          children: [
            // === 1. Avatar (Positioned di atas) ===
            Positioned(
              top: -50.h, // menjorok 50 logical pixel ke atas
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1.r,
                        blurRadius: 4.r,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60.r,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: SizedBox(
                        width: 120.w,
                        height: 120.w,
                        child: _buildProfileImage(photoUrl),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // === 2. Scrollable list info di bawah avatar ===
            Positioned(
              top: 60.h, // beri jarak 60 agar tidak tertutup avatar
              left: 0,
              right: 0,
              bottom: 0, // “isi” sampai bawah container
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    _buildInfoSection(
                        context, 'NIP', nip, Icons.badge_outlined),
                    _buildInfoSection(
                        context, 'Nama', name, Icons.person_outline),
                    _buildInfoSection(
                        context, 'Jabatan', position, Icons.work_outline),
                    _buildInfoSection(context, 'Divisi', divisionName,
                        Icons.business_center_outlined),
                    _buildInfoSection(context, 'Perusahaan', companyName,
                        Icons.corporate_fare_outlined),
                    _buildInfoSection(context, 'Tipe Perusahaan', companyType,
                        Icons.category_outlined),
                    _buildInfoSection(context, 'Alamat Perusahaan', location,
                        Icons.location_on_outlined),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        );
      });
    });
  }

  /// Membuat satu baris info (label + value) dengan ikon
  Widget _buildInfoSection(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 22.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Menangani berbagai format foto (base64/dataURL atau URL)
  Widget _buildProfileImage(String photo) {
    if (photo.startsWith("data:image")) {
      try {
        final base64Str = photo.contains(',') ? photo.split(',')[1] : photo;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.person, color: Colors.grey, size: 40.w),
        );
      } catch (e) {
        print('Error decoding Base64: $e');
        return Icon(Icons.person, color: Colors.grey, size: 40.w);
      }
    }

    if (photo.startsWith("http")) {
      return Image.network(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.person, color: Colors.grey, size: 40.w),
      );
    }

    return Icon(Icons.person, color: Colors.grey, size: 40.w);
  }
}
