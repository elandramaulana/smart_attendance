import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance/controller/approval_controller.dart';
import 'package:smart_attendance/widget/approval_list_widget.dart';

class ApprovalPage extends GetView<ApprovalController> {
  const ApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient and decorations
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
              width: 200,
              height: 200,
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
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100.withOpacity(0.2),
              ),
            ),
          ),
          // Back button
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
          // Content area
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
                  padding: EdgeInsets.all(16.h),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.errorMessage.isNotEmpty) {
                      return Center(child: Text(controller.errorMessage.value));
                    }
                    final list = controller.approvals;
                    if (list.isEmpty) {
                      return const Center(
                          child: Text('Tidak ada data approval'));
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20.h),
                          ...list.map((item) {
                            final rawType = item.approvalType;

                            final dateStr = DateFormat('dd MMM yyyy, HH:mm')
                                .format(item.date.toLocal());

                            final description = controller.description(item);

                            return ApprovalListItem(
                              nama: item.name,
                              approvalType: rawType,
                              dateTime: dateStr,
                              status: item.status,
                              description: description,
                              reason: item.reason,
                              onApprove: item.status.toLowerCase() == 'pending'
                                  ? () => controller.approve(item)
                                  : null,
                              onReject: item.status.toLowerCase() == 'pending'
                                  ? () => controller.reject(item)
                                  : null,
                            );
                          }),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  })),
            ),
          ),
        ],
      ),
    );
  }
}
