import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IzinListItem extends StatelessWidget {
  final String title;
  final String dateTime;
  final String status;
  final String description;
  final VoidCallback? onTap;

  const IzinListItem({
    super.key,
    required this.title,
    required this.dateTime,
    required this.status,
    required this.description,
    this.onTap,
  });

  // Warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'approved':
        return const Color(0xFF26A69A);
      case 'rejected':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF78909C);
    }
  }

  // Warna latar belakang card berdasarkan status
  Color _getCardBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'approved':
        return const Color(0xFFE0F2F1);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFECEFF1);
    }
  }

  // Mendapatkan ikon berdasarkan jenis izin/title
  IconData _getIzinIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('cuti') || titleLower.contains('liburan')) {
      return Icons.beach_access_outlined;
    } else if (titleLower.contains('keluarga') ||
        titleLower.contains('acara')) {
      return Icons.family_restroom_outlined;
    } else if (titleLower.contains('dinas') || titleLower.contains('tugas')) {
      return Icons.work_outline_outlined;
    } else if (titleLower.contains('pendidikan') ||
        titleLower.contains('belajar')) {
      return Icons.school_outlined;
    } else if (titleLower.contains('darurat') ||
        titleLower.contains('penting')) {
      return Icons.warning_amber_outlined;
    } else {
      return Icons.event_available_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memisahkan tanggal dan waktu jika formatnya sesuai
    List<String> parts = dateTime.split(' · ');
    String date = parts.isNotEmpty ? parts[0] : dateTime;
    String time = parts.length > 1 ? parts[1] : '';

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.h,
        horizontal: 16.w,
      ),
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
                    // Judul dengan ikon
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor:
                                _getStatusColor(status).withOpacity(0.2),
                            child: Icon(
                              _getIzinIcon(title),
                              color: _getStatusColor(status),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              title,
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

                // Date Section
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.access_time_rounded,
                        size: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 10.h),

                // Keterangan Izin Section
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.blue.shade100,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Keterangan Izin Header
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 16.sp,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Keterangan Izin',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      // Deskripsi / Keterangan Izin
                      Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade800,
                          ),
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
    );
  }
}
