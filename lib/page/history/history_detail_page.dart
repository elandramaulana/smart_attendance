import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/model/history_model.dart';
import 'package:smart_attendance/utils/datetime_util.dart';
import 'package:smart_attendance/core/app_routes.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    debugPrint('HistoryDetailPage arguments: $args');

    if (args is! History) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Data riwayat tidak valid atau tidak tersedia.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final History history = args;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blueGrey.shade600,
                  Colors.blueGrey.shade800,
                ],
              ),
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
                color: Colors.green.shade100.withOpacity(0.2),
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
                color: Colors.blue.shade100.withOpacity(0.2),
              ),
            ),
          ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.85,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      IndonesianDateFormatter.formatTanggalLengkap(
                          history.date),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimeCard(
                            icon: Icons.login_rounded,
                            label: 'Masuk',
                            time: history.inTime,
                            status: history.inStatus,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          // _buildTimeCard(
                          //   icon: Icons.coffee_rounded,
                          //   label: 'Break',
                          //   time: history.breakTime,
                          //   status: history.breakStatus,
                          //   color: Colors.orange.shade700,
                          // ),
                          _buildTimeCard(
                            icon: Icons.logout_rounded,
                            label: 'Keluar',
                            time: history.outTime,
                            status: history.outStatus,
                            color: Colors.red.shade700,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPhotoSection(
                              context, history.inSelfie, 'Masuk'),
                          // _buildPhotoSection(
                          //     context, history.breakSelfie, 'Break'),
                          SizedBox(
                            width: 10.w,
                          ),
                          _buildPhotoSection(
                              context, history.outSelfie, 'Keluar'),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          if (history.note != null) ...[
                            SizedBox(height: 16.h),
                            _buildDetailRow(
                              label: 'Keterangan',
                              value: history.note!,
                              icon: Icons.note_alt_outlined,
                            ),
                          ],
                          SizedBox(height: 24.h),
                          _buildCorrectionButton(context, history),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String label,
    String? time,
    String? status,
    required Color color,
  }) {
    final displayTime = (time != null && time.length >= 5)
        ? time.substring(0, 5)
        : (time ?? '-');

    String? statusText;
    Color? statusColor;
    if (status != null) {
      switch (status.toLowerCase()) {
        case 'late':
          statusText = 'Terlambat';
          statusColor = Colors.red;
          break;
        case 'early':
          statusText = 'Lebih Awal';
          statusColor = Colors.red;
          break;
        case 'ontime':
          statusText = 'Tepat Waktu';
          statusColor = Colors.green;
          break;
        case 'tolerance':
          statusText = 'Toleransi';
          statusColor = Colors.yellow.shade700;
          break;
        default:
          statusText = status;
          statusColor = color;
      }
    }

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(label,
              style: TextStyle(
                  fontSize: 12.sp, color: color, fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          Text(displayTime,
              style: TextStyle(
                  fontSize: 14.sp, color: color, fontWeight: FontWeight.w600)),
          if (statusText != null) ...[
            SizedBox(height: 4.h),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11.sp,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
      BuildContext context, String? photoUrl, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 8.h),
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: photoUrl != null
                  ? () => _showEnlargedPhoto(context, photoUrl)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) => progress ==
                                  null
                              ? child
                              : Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                          errorBuilder: (ctx, err, st) => Center(
                            child: Icon(Icons.error_outline,
                                color: Colors.red, size: 30.sp),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.photo_size_select_actual_outlined,
                            size: 30.sp, color: Colors.grey.shade400),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEnlargedPhoto(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10.w),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Image.network(photoUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildCorrectionButton(BuildContext context, History history) {
    return ElevatedButton(
      onPressed: () => Get.toNamed(AppRoutes.correction, arguments: history),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade700,
        minimumSize: Size(double.infinity, 50.h),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      ),
      child: Text('Ajukan Koreksi',
          style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A6AFF), size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text(value,
                    style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
