import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/correction_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/utils/datetime_util.dart';

class CorrectionPage extends GetView<CorrectionController> {
  const CorrectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data History & tanggal dari controller
    final history = controller.history;
    final dateText =
        IndonesianDateFormatter.formatTanggalLengkap(controller.selectedDate);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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

          // Decorative circles
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

          // Content card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.80,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tanggal absensi (read-only)
                        _buildDateDisplay(dateText),
                        SizedBox(height: 16.h),

                        // Dropdown jenis koreksi
                        _buildAbsenceTypeDropdown(),
                        SizedBox(height: 16.h),

                        // Time picker
                        _buildTimePicker(context),
                        SizedBox(height: 16.h),

                        // Alasan koreksi
                        _buildReasonField(),
                        SizedBox(height: 24.h),

                        // Tombol submit
                        _buildSubmitButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(String dateText) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Tanggal Absensi',
        labelStyle: TextStyle(color: Colors.blueGrey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.blueGrey[700]!, width: 2),
        ),
      ),
      child: Text(
        dateText,
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Widget _buildAbsenceTypeDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.selectedAbsenceType.value.isEmpty
            ? null
            : controller.selectedAbsenceType.value,
        hint: Text('Pilih Jenis Koreksi'),
        decoration: InputDecoration(
          labelText: 'Jenis Koreksi',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.blueGrey[700]!, width: 2),
          ),
        ),
        items: controller.absenceTypes.map((type) {
          String label;
          switch (type) {
            case 'in':
              label = 'Masuk';
              break;
            case 'out':
              label = 'Keluar';
              break;
            default:
              label = type;
          }
          return DropdownMenuItem(value: type, child: Text(label));
        }).toList(),
        onChanged: (value) {
          if (value != null) controller.selectAbsenceType(value);
        },
      );
    });
  }

  Widget _buildTimePicker(BuildContext context) {
    return Obx(() {
      final selectedTime = controller.selectedTime.value;
      final timeText =
          selectedTime != null ? selectedTime.format(context) : 'Pilih Jam';

      return InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? TimeOfDay.now(),
            builder: (c, child) => Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blueGrey[700]!,
                ),
              ),
              child: child!,
            ),
          );
          if (picked != null) controller.selectTime(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Jam Koreksi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.blueGrey[700]!, width: 2),
            ),
            suffixIcon: Icon(Icons.access_time, color: Colors.blueGrey[700]),
          ),
          child: Text(timeText, style: TextStyle(fontSize: 16.sp)),
        ),
      );
    });
  }

  Widget _buildReasonField() {
    return TextField(
      onChanged: (value) => controller.reason.value = value,
      decoration: InputDecoration(
        labelText: 'Alasan Koreksi',
        hintText: 'Masukkan alasan...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.blueGrey[700]!, width: 2),
        ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : () async {
                final success = await controller.submitCorrection();
                if (success) {
                  _showConfirmation(context);
                }

                Get.offAllNamed(AppRoutes.bottomNav);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[700],
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: controller.isSubmitting.value
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Kirim Koreksi',
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
      );
    });
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Icon(Icons.check_circle_outline,
            color: Colors.green.shade700, size: 60.sp),
        content: Text(
          'Pengajuan koreksi berhasil dikirim Mohon menunggu persetujuan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
            ),
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
