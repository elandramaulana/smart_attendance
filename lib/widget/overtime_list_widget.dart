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
    return Container(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: _getStatusColor(status).withOpacity(0.2),
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
                    SizedBox(width: 8.w),
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
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        dateRange,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Time Section
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.login_rounded,
                                size: 16.sp,
                                color: Colors.green.shade700,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vertical Divider
                        VerticalDivider(
                          width: 20.w,
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),

                        // End Time
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                size: 16.sp,
                                color: Colors.red.shade700,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
