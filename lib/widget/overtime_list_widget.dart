import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LemburListItem extends StatelessWidget {
  final String employeeName;
  final String dateRange;
  final String startTime;
  final String endTime;
  final String status;
  final VoidCallback? onTap;

  const LemburListItem({
    super.key,
    required this.employeeName,
    required this.dateRange,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.onTap,
  });

  // Warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726); // Oranye yang lebih cerah
      case 'approved':
        return const Color(0xFF26A69A); // Teal yang lebih cerah
      case 'rejected':
        return const Color(0xFFEF5350); // Merah yang lebih cerah
      default:
        return const Color(0xFF78909C); // BlueGrey yang lebih cerah
    }
  }

  // Warna latar belakang card berdasarkan status
  Color _getCardBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFF3E0); // Oranye muda
      case 'approved':
        return const Color(0xFFE0F2F1); // Teal muda
      case 'rejected':
        return const Color(0xFFFFEBEE); // Merah muda
      default:
        return const Color(0xFFECEFF1); // BlueGrey muda
    }
  }

  // // Hitung durasi lembur
  // String _calculateDuration() {
  //   try {
  //     // Parse waktu dalam format 24 jam (asumsi format: HH:mm)
  //     final List<String> startParts = startTime.split(':');
  //     final List<String> endParts = endTime.split(':');

  //     if (startParts.length >= 2 && endParts.length >= 2) {
  //       int startHour = int.tryParse(startParts[0]) ?? 0;
  //       int startMinute = int.tryParse(startParts[1]) ?? 0;
  //       int endHour = int.tryParse(endParts[0]) ?? 0;
  //       int endMinute = int.tryParse(endParts[1]) ?? 0;

  //       // Konversi ke menit total
  //       int startTotalMinutes = startHour * 60 + startMinute;
  //       int endTotalMinutes = endHour * 60 + endMinute;

  //       // Jika waktu akhir lebih kecil dari waktu mulai, asumsi melewati tengah malam
  //       if (endTotalMinutes < startTotalMinutes) {
  //         endTotalMinutes += 24 * 60; // Tambah 24 jam dalam menit
  //       }

  //       int durationMinutes = endTotalMinutes - startTotalMinutes;
  //       int hours = durationMinutes ~/ 60;
  //       int minutes = durationMinutes % 60;

  //       return '${hours}j ${minutes}m';
  //     }
  //   } catch (e) {
  //     // Error handling
  //   }

  //   return '-';
  // }

  @override
  Widget build(BuildContext context) {
    // final String duration = _calculateDuration();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: _getStatusColor(status),
                  width: 6.w,
                ),
              ),
              color: _getCardBackgroundColor(status).withOpacity(0.3),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nama karyawan dengan ikon
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor:
                                _getStatusColor(status).withOpacity(0.2),
                            child: Icon(
                              Icons.work_outline_rounded,
                              color: _getStatusColor(status),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              employeeName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status label
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 10.w,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        status == 'Approved'
                            ? 'Disetujui'
                            : status == 'Rejected'
                                ? 'Ditolak'
                                : 'Menunggu',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Divider
                Divider(
                  height: 1.h,
                  thickness: 1.h,
                  color: Colors.grey.withOpacity(0.2),
                ),

                SizedBox(height: 12.h),

                // Content Section
                // Tanggal
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Waktu & Durasi area
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      // Waktu mulai dan selesai
                      Row(
                        children: [
                          // Waktu mulai
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  size: 16.sp,
                                  color: Colors.green.shade700,
                                ),
                                SizedBox(width: 8.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mulai',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      startTime,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Waktu selesai
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  size: 16.sp,
                                  color: Colors.red.shade700,
                                ),
                                SizedBox(width: 8.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selesai',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      endTime,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // SizedBox(height: 8.h),

                      // // Divider
                      // Divider(
                      //   height: 1.h,
                      //   thickness: 1.h,
                      //   color: Colors.grey.withOpacity(0.15),
                      // ),

                      // SizedBox(height: 8.h),

                      // // Durasi
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Icons.timer_outlined,
                      //       size: 16.sp,
                      //       color: Colors.indigo.shade700,
                      //     ),
                      //     SizedBox(width: 8.w),
                      //     Text(
                      //       'Durasi: ',
                      //       style: TextStyle(
                      //         fontSize: 12.sp,
                      //         color: Colors.grey.shade600,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
