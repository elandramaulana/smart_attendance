import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance/model/correction_history_model.dart';

class CorrectionListItem extends StatelessWidget {
  final CorrectionListModel item;

  const CorrectionListItem({
    super.key,
    required this.item,
  });

  // Icon berdasarkan jenis koreksi
  IconData _getCorrectionIcon(String correctionType) {
    switch (correctionType.toLowerCase()) {
      case 'clock in':
        return Icons.login_rounded;
      case 'clock out':
        return Icons.logout_rounded;
      // case 'break':
      //   return Icons.pause_rounded;
      default:
        return Icons.edit_calendar_rounded;
    }
  }

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
    // Format tanggal jadi "dd MMM yyyy"
    final dateFormat = DateFormat('dd MMM yyyy');
    final date = dateFormat.format(item.correctionDate.toLocal());

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
          onTap: () {
            // Handle tap action here
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: _getStatusColor(item.correctionStatus),
                  width: 6.w,
                ),
              ),
              color: _getCardBackgroundColor(item.correctionStatus)
                  .withOpacity(0.3),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Jenis koreksi dengan ikon
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor:
                                _getStatusColor(item.correctionStatus)
                                    .withOpacity(0.2),
                            child: Icon(
                              _getCorrectionIcon(item.correctionType),
                              color: _getStatusColor(item.correctionStatus),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              item.correctionType == 'Clock In'
                                  ? 'Masuk'
                                  : 'Pulang',
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
                        color: _getStatusColor(item.correctionStatus),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        item.correctionStatus == 'Approved'
                            ? 'Disetujui'
                            : item.correctionStatus == 'Rejected'
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
                // Employee Name
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 18.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.employeeName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Date and Time
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
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time_rounded,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      item.actualTime,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
