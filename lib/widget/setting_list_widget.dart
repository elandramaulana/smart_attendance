import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_attendance/controller/profile_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';

class SettingListWidget extends GetView<ProfileController> {
  SettingListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah di-instansiasi
    final profileController = Get.put(ProfileController());

    return Obx(() {
      final p = profileController.profile.value;

      // Fallback foto default
      final photo = (p?.profilePicture.isNotEmpty == true)
          ? p!.profilePicture
          : 'https://icons.veryicon.com/png/o/application/a-group-of-common-linear-icon/walk-1.png';

      final fullName = p?.fullName ?? '';
      final position = p?.positionName ?? '';
      final nip = p?.noEmployee ?? '';

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0.w),
                child: Row(
                  children: [
                    // Profile Picture
                    ClipOval(
                      child: Container(
                        width: 60.w,
                        height: 60.w,
                        color: Colors.grey[200],
                        child: photo.startsWith('data:image/')
                            ? Image.memory(
                                base64Decode(photo.split(',')[1]),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.broken_image, size: 40.w),
                              )
                            : Image.network(
                                photo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.broken_image, size: 40.w),
                              ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            position,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            nip,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  'Perbarui Foto',
                  onTap: () => _showChangePictureDialog(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                logoutButton(
                  title: 'Logout',
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showLogoutDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Konfirmasi Logout",
      middleText: "Apakah Anda yakin ingin logout?",
      textConfirm: "Ya",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        controller.logout(); // Panggil logout di ProfileController
      },
      onCancel: () {},
    );
  }

  Widget logoutButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title, {
    Color? textColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor ?? const Color(0xFF424242),
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF757575),
                  size: 20.sp,
                ),
          ],
        ),
      ),
    );
  }

  void _showChangePictureDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Photo Library'),
              onTap: () => controller.changeProfilePicture(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () => controller.changeProfilePicture(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
