import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ApprovalListItem extends StatelessWidget {
  final String nama;
  final String approvalType; // misal "sick_permit"
  final String dateTime;
  final String status;
  final String description; // rentang tanggal
  final String reason;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ApprovalListItem({
    super.key,
    required this.nama,
    required this.approvalType,
    required this.dateTime,
    required this.status,
    required this.description,
    required this.reason,
    this.onApprove,
    this.onReject,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'disetujui':
        return Colors.teal;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'correction':
        return Colors.amber.shade300;
      case 'leave':
        return Colors.green.shade300;
      case 'overtime':
        return Colors.blue.shade300;
      case 'sick_permit':
        return Colors.red.shade300;
      default:
        return Colors.indigo.shade300;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'correction':
        return 'Koreksi';
      case 'leave':
        return 'Cuti';
      case 'overtime':
        return 'Lembur';
      case 'sick_permit':
        return 'Sakit/Izin';
      default:
        // kalau ada type baru
        return type.replaceAll('_', ' ').capitalize!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPending = status.toLowerCase() == 'pending';
    final typeLabel = _getTypeLabel(approvalType);
    final typeColor = _getTypeColor(approvalType);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // strip status color
            Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),
            // content card
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h))
                  ],
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    Text(
                      nama,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Tanggal request
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14.sp, color: Colors.teal),
                        SizedBox(width: 4.w),
                        Text(
                          'Periode: $description',
                          style: TextStyle(fontSize: 13.sp, color: Colors.teal),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Periode
                    Text(
                      'Pengajuan: $dateTime',
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.grey.shade600),
                    ),

                    SizedBox(height: 4.h),

                    // Alasan
                    Text(
                      'Alasan: $reason',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                      softWrap: true, // pastikan membungkus
                    ),

                    // Status & Type badges
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.h, horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Type badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.h, horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    // Action buttons
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isPending ? () => onReject?.call() : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                            padding: EdgeInsets.symmetric(
                                vertical: 4.h, horizontal: 12.w),
                          ),
                          child: Text('Tolak',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isPending ? Colors.red : Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: isPending ? () => onApprove?.call() : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPending ? Colors.teal : Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                            padding: EdgeInsets.symmetric(
                                vertical: 4.h, horizontal: 12.w),
                          ),
                          child: Text('Setujui',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
