import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/buttom_nav_controller.dart';
import 'package:smart_attendance/controller/history_controller.dart';
import 'package:smart_attendance/controller/home_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/history_model.dart';

class HistoryCard extends StatelessWidget {
  final History history;
  const HistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Format date to "02 Mar 2023"
    final String formattedDate = DateFormat('dd MMM yyyy').format(history.date);

    return GestureDetector(
      onTap: () {
        // Navigasi sambil bawa seluruh object History
        Get.toNamed(
          AppRoutes.historyDetail,
          arguments: history,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date with calendar icon
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 14.sp,
                            color: const Color.fromARGB(255, 28, 29, 29)),
                        SizedBox(width: 6.w),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: history.note.toString() == "null"
                          ? Colors.green.shade600
                          : history.note.toString() == "Leave"
                              ? Colors.amber.shade600
                              : history.note.toString() == "Sick/Permit"
                                  ? Colors.blue.shade600
                                  : Colors.red.shade600,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          history.note.toString() == "null"
                              ? "Hadir"
                              : history.note.toString() == "Leave"
                                  ? "Cuti"
                                  : history.note.toString() == "Sick/Permit"
                                      ? "Sakit/Izin"
                                      : history.note.toString(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Time info in a modern layout
              Row(
                children: [
                  _buildTimeInfo(
                    icon: Icons.login_rounded,
                    label: "Masuk",
                    time: history.inTime.toString() == "null"
                        ? "-"
                        : history.inTime.toString(),
                    color: Colors.green.shade600,
                  ),
                  Container(
                    height: 40.h,
                    width: 1,
                    color: Colors.grey.shade200,
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                  _buildTimeInfo(
                    icon: Icons.coffee_rounded,
                    label: "Break",
                    time: history.breakTime.toString() == "null"
                        ? "-"
                        : history.breakTime.toString(),
                    color: Colors.amber.shade600,
                  ),
                  Container(
                    height: 40.h,
                    width: 1,
                    color: Colors.grey.shade200,
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                  _buildTimeInfo(
                    icon: Icons.logout_rounded,
                    label: "Keluar",
                    time: history.outTime.toString() == "null"
                        ? "-"
                        : history.outTime.toString(),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    final String formattedTime = time.length >= 5 ? time.substring(0, 5) : time;
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryList extends GetView<HistoryController> {
  final bool isHome;
  const HistoryList({super.key, this.isHome = false});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    return Column(
      children: [
        // Fixed header that doesn't scroll
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 0.h, 14.w, 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Obx(() {
                    String title = 'History';
                    if (controller.isFilterActive.value) {
                      title =
                          'History - ${controller.monthName} ${controller.selectedYear.value}';
                    }
                    return Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.2,
                      ),
                    );
                  }),
                ],
              ),
              if (isHome)
                TextButton(
                  onPressed: () {
                    final bottomNavCtrl = Get.find<BottomNavController>();
                    bottomNavCtrl.navController.jumpToTab(1);
                    Get.offNamed(AppRoutes.bottomNav);
                  },
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Selengkapnya',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Scrollable content (history cards)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final now = DateTime.now();
              late DateTime startDate, endDate;

              if (controller.isFilterActive.value) {
                final m = controller.selectedMonth.value;
                final y = controller.selectedYear.value;
                startDate = DateTime(y, m, 1);
                endDate =
                    m < 12 ? DateTime(y, m + 1, 0) : DateTime(y + 1, 1, 0);
              } else {
                startDate = DateTime(now.year, now.month, 1);
                endDate = now;
              }

              await controller.fetchHistory(
                startDate: startDate,
                endDate: endDate,
              );

              // 2. baru fetchTodayAttendance
              await homeController.fetchTodayAttendance();
            },
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final histories = controller.histories;
              if (histories.isEmpty) {
                return SizedBox(
                  height: 300.h,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 48.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          controller.isFilterActive.value
                              ? "No attendance records for ${controller.monthName} ${controller.selectedYear.value}"
                              : "No attendance records yet",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final displayedHistories =
                  isHome ? histories.take(5).toList() : histories;

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: displayedHistories.length + 1,
                itemBuilder: (context, index) {
                  if (index < displayedHistories.length) {
                    return HistoryCard(history: displayedHistories[index]);
                  }
                  return SizedBox(height: 16.h);
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}



// LinearGradient getBackgroundGradient(String? note) {
//   // Definisikan warna untuk setiap kategori note
//   final Color endColor;

//   if (note == null) {
//     // Warna blue green untuk note = null
//     endColor = Colors.blueGrey.shade100;
//   } else if (note.toLowerCase() == "leave") {
//     // Warna amber untuk "leave"
//     endColor = Colors.amber.shade50;
//   } else if (note.toLowerCase() == "sick/permit" ||
//       note.toLowerCase() == "sick" ||
//       note.toLowerCase() == "permit") {
//     // Warna blue untuk "Sick/Permit"
//     endColor = Colors.blue.shade50;
//   } else {
//     // Warna red untuk semua nilai lainnya
//     endColor = Colors.red.shade50;
//   }

//   return LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [Colors.white, endColor],
//   );
// }