import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SakitListItem extends StatelessWidget {
  final String title;
  final String dateTime;
  final String status;
  final String description;
  final VoidCallback? onTap;

  const SakitListItem({
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

  // Mendapatkan ikon berdasarkan jenis sakit/title
  IconData _getSakitIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('covid') || titleLower.contains('corona')) {
      return Icons.coronavirus_outlined;
    } else if (titleLower.contains('demam') || titleLower.contains('panas')) {
      return Icons.thermostat_outlined;
    } else if (titleLower.contains('flu') || titleLower.contains('pilek')) {
      return Icons.sick_outlined;
    } else if (titleLower.contains('kepala') ||
        titleLower.contains('migrain')) {
      return Icons.sentiment_very_dissatisfied_outlined;
    } else if (titleLower.contains('perut') || titleLower.contains('mual')) {
      return Icons.bubble_chart_outlined;
    } else {
      return Icons.medical_services_rounded;
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
                              _getSakitIcon(title),
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

                // Medical Info Section
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.red.shade100,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Keterangan Sakit Header
                      Row(
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 16.sp,
                            color: Colors.red.shade700,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Keterangan Sakit',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      // Deskripsi / Keterangan Sakit
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

                // // Indicator for medical document (optional feature)
                // SizedBox(height: 10.h),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Icon(
                //       Icons.attach_file,
                //       size: 14.sp,
                //       color: _getStatusColor(status),
                //     ),
                //     SizedBox(width: 4.w),
                //     Text(
                //       'Surat Keterangan Dokter',
                //       style: TextStyle(
                //         fontSize: 12.sp,
                //         color: _getStatusColor(status),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
