import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/correction_list_controller.dart';
import 'package:smart_attendance/widget/correction_list_widget.dart';

class HistoryListCorrection extends GetView<CorrectionListController> {
  const HistoryListCorrection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownDeco = InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
    );
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

          // Back Button
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

          // Detail Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                    offset: Offset(0, -4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    // dropdown Bulan & Tahun
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<String>(
                                decoration:
                                    dropdownDeco.copyWith(labelText: 'Bulan'),
                                value: controller.selectedMonth.value,
                                items: controller.months
                                    .map((m) => DropdownMenuItem(
                                        value: m, child: Text(m)))
                                    .toList(),
                                onChanged: (v) =>
                                    controller.selectedMonth.value = v!,
                              )),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<int>(
                                decoration:
                                    dropdownDeco.copyWith(labelText: 'Tahun'),
                                value: controller.selectedYear.value,
                                items: controller.years
                                    .map((y) => DropdownMenuItem(
                                        value: y, child: Text('$y')))
                                    .toList(),
                                onChanged: (v) =>
                                    controller.selectedYear.value = v!,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // list koreksi
                    Expanded(
                      child: Obx(() {
                        return RefreshIndicator(
                            onRefresh: () async {
                              await controller.fetchCorrection();
                            },
                            child: controller.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : controller.listCorrection.isEmpty
                                    ? ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        children: const [
                                          SizedBox(height: 100),
                                          Center(
                                              child: Text(
                                                  "Tidak ada data koreksi kehadiran")),
                                        ],
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount:
                                            controller.listCorrection.length,
                                        itemBuilder: (_, i) {
                                          final a =
                                              controller.listCorrection[i];
                                          return Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 12.h),
                                            child: CorrectionListItem(
                                              item: a,
                                            ),
                                          );
                                        },
                                      ));
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
