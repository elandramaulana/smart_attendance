import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/history_controller.dart';
import 'package:smart_attendance/controller/profile_controller.dart';
import 'package:smart_attendance/widget/history_list_widget.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double profilePictureSize = screenWidth * 0.15; // 15% of screen width
    final double cardPadding = screenWidth * 0.02;
    final double iconSize = screenWidth * 0.05;

    final profileController = Get.put(ProfileController());
    return Scaffold(
        body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
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
              color: Colors.green.shade100.withOpacity(0.3),
            ),
          ),
        ),
        // Siluet bawah kanan
        Positioned(
          bottom: -30,
          right: -30,
          child: Container(
            width: 150.w,
            height: 150.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade100.withOpacity(0.3),
            ),
          ),
        ),
        // Aksen tambahan
        Positioned(
          bottom: 50,
          left: 50,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade100.withOpacity(0.3),
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: screenHeight * 0.78,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400.withOpacity(0.6),
                  offset: const Offset(0, -4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Filter widget
                _buildFilterWidget(),

                // History list
                const Expanded(
                  child: HistoryList(isHome: false),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              // Obx untuk rebuild otomatis saat profile/isLoading/errorMessage berubah
              child: Obx(() {
                // 1. Loading state
                if (profileController.isLoading.value) {
                  return SizedBox(
                    height: screenHeight * 0.08,
                    child: Center(
                      child: SizedBox(
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                // 2. Error state
                if (profileController.errorMessage.isNotEmpty) {
                  return Container(
                    height: screenHeight * 0.08,
                    alignment: Alignment.center,
                    child: Text(
                      profileController.errorMessage.value,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  );
                }
                // 3. Data siap
                final p = profileController.profile.value;
                final photo = (p?.logo.isNotEmpty == true)
                    ? p!.logo
                    : 'https://icons.veryicon.com/png/o/application/a-group-of-common-linear-icon/walk-1.png';

                final company = p?.companyName ?? '';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: profilePictureSize,
                      height: profilePictureSize,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        // Tambahkan border jika perlu
                        border: Border.all(
                          color: Colors.grey, // warna border
                          width: 1.0, // ketebalan border
                        ),
                        // Jika kamu mau sudut membulat sedikit, atur BorderRadius
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: photo.startsWith('data:image/')
                          ? Image.memory(
                              base64Decode(photo.split(',')[1]),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image,
                                  size: profilePictureSize * 0.7),
                            )
                          : Image.network(
                              photo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image,
                                  size: profilePictureSize * 0.7),
                            ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildFilterWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Month',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Obx(() => controller.isFilterActive.value
                  ? TextButton(
                      onPressed: controller.resetFilter,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    )
                  : SizedBox()),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              // Month dropdown
              Expanded(
                child: _buildMonthDropdown(),
              ),
              SizedBox(width: 12.w),
              // Year dropdown
              Expanded(
                child: _buildYearDropdown(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<int>(
              isExpanded: true,
              value: controller.selectedMonth.value,
              items: List.generate(12, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(months[index]),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  controller.filterByMonth(
                      value, controller.selectedYear.value);
                }
              },
            )),
      ),
    );
  }

  Widget _buildYearDropdown() {
    // Generate a list of years (current year and 2 years before)
    final currentYear = DateTime.now().year;
    final years = [currentYear, currentYear - 1, currentYear - 2];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<int>(
              isExpanded: true,
              value: controller.selectedYear.value,
              items: years.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.filterByMonth(
                      controller.selectedMonth.value, value);
                }
              },
            )),
      ),
    );
  }
}
