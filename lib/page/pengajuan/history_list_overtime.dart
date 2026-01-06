import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/overtime_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/widget/overtime_list_widget.dart';

class HistoryListLembur extends GetView<OvertimeController> {
  const HistoryListLembur({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    final screenHeight = MediaQuery.of(context).size.height;

    final dropdownDeco = InputDecoration(
      labelStyle: TextStyle(fontSize: 14.sp),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.formLembur),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // Background Gradient
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

          // Dekorasi lingkaran hijau
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

          // Dekorasi lingkaran biru
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

          // Tombol back
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

          // Konten putih
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
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  children: [
                    // Filter Row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<String>(
                                  decoration: dropdownDeco.copyWith(
                                    labelText: 'Bulan',
                                  ),
                                  value: ctrl.selectedMonth.value,
                                  items: ctrl.months
                                      .map((m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) ctrl.selectedMonth.value = v;
                                  },
                                )),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<int>(
                                  decoration: dropdownDeco.copyWith(
                                    labelText: 'Tahun',
                                  ),
                                  value: ctrl.selectedYear.value,
                                  items: ctrl.years
                                      .map((y) => DropdownMenuItem(
                                            value: y,
                                            child: Text(y.toString()),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) ctrl.selectedYear.value = v;
                                  },
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // List Lembur
                    Expanded(
                      child: Obx(() {
                        return RefreshIndicator(
                          onRefresh: () async {
                            await ctrl.fetchAll(null);
                          },
                          child: ctrl.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ctrl.listOvertime.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        SizedBox(height: 100),
                                        Center(
                                          child: Text("Tidak ada data lembur"),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: ctrl.listOvertime.length,
                                      itemBuilder: (context, i) {
                                        final o = ctrl.listOvertime[i];
                                        final startDate = o.dateStart
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0];
                                        final endDate = o.dateEnd
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0];

                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 8.h,
                                          ),
                                          child: LemburListItem(
                                            employeeName: o.employeeName,
                                            dateRange: "$startDate → $endDate",
                                            startTime: o.timeStart,
                                            endTime: o.timeEnd,
                                            status: o.status,
                                          ),
                                        );
                                      },
                                    ),
                        );
                      }),
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
}
