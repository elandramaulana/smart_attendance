import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/utils/text_formatter_helper.dart';

class CutiListItem extends StatelessWidget {
  final String title;
  final String dateTime;
  final String status;
  final String description;
  final int duration;
  final VoidCallback? onTap;

  const CutiListItem({
    super.key,
    required this.title,
    required this.dateTime,
    required this.status,
    required this.description,
    required this.duration,
    this.onTap,
  });

  // Icon berdasarkan judul/tipe cuti
  IconData _getCutiIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('tahunan')) {
      return Icons.beach_access_rounded;
    } else if (titleLower.contains('sakit')) {
      return Icons.medical_services_rounded;
    } else if (titleLower.contains('melahirkan') ||
        titleLower.contains('bersalin')) {
      return Icons.pregnant_woman_rounded;
    } else if (titleLower.contains('penting')) {
      return Icons.event_busy_rounded;
    } else if (titleLower.contains('besar')) {
      return Icons.celebration_outlined;
    } else if (titleLower.contains('pendidikan')) {
      return Icons.school_outlined;
    } else {
      return Icons.event_available_rounded;
    }
  }

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
                              _getCutiIcon(title),
                              color: _getStatusColor(status),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              TextFormatterHelper.formatLeaveType(title),
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
                    SizedBox(width: 8.w),
                    Text(
                      '($duration hari)',
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

                // Keterangan Cuti Section
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.green.shade100,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Keterangan Cuti Header
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 16.sp,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Keterangan Cuti',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      // Deskripsi / Keterangan Cuti
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
