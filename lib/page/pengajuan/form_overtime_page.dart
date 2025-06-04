import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/overtime_controller.dart';

class FormOvertimePage extends GetView<OvertimeController> {
  const FormOvertimePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah di-bind di binding atau di sini:
    final ctrl = Get.put(OvertimeController());

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Form Pengajuan Lembur',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Obx(() {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: GlobalKey(),
                child: ListView(
                  children: [
                    SizedBox(height: 16.h),

                    // Tanggal Mulai
                    TextFormField(
                      controller: ctrl.startDateController,
                      readOnly: true,
                      onTap: () => ctrl.pickDateStart(context),
                      decoration: InputDecoration(
                        labelText: "Tanggal Mulai",
                        hintText: "Pilih tanggal",
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Pilih tanggal" : null,
                    ),
                    SizedBox(height: 16.h),

                    // Tanggal Akhir
                    TextFormField(
                      controller: ctrl.endDateController,
                      readOnly: true,
                      onTap: () => ctrl.pickDateEnd(context),
                      decoration: InputDecoration(
                        labelText: "Tanggal Akhir",
                        hintText: "Pilih tanggal",
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Pilih tanggal" : null,
                    ),
                    SizedBox(height: 16.h),

                    // Jam Mulai
                    _buildTimePicker(
                      context,
                      label: "Jam Mulai",
                      selected: ctrl.timeStart,
                      onTap: ctrl.pickTimeStart,
                    ),
                    SizedBox(height: 16.h),

                    // Jam Selesai
                    _buildTimePicker(
                      context,
                      label: "Jam Selesai",
                      selected: ctrl.timeEnd,
                      onTap: ctrl.pickTimeEnd,
                    ),
                    SizedBox(height: 16.h),

                    // Deskripsi
                    TextFormField(
                      controller: ctrl.descriptionController,
                      decoration: InputDecoration(
                        labelText: "Alasan Lembur",
                        hintText: "Tuliskan alasan pengajuan lembur",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                      maxLines: 3,
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Masukkan alasan lembur"
                          : null,
                    ),
                    SizedBox(height: 24.h),

                    // Tombol Submit
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      onPressed: ctrl.isLoading.value ? null : ctrl.submitForm,
                      child: const Text(
                        "Ajukan Lembur",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (ctrl.isLoading.value)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required Rxn<TimeOfDay> selected,
    required Future<void> Function(BuildContext) onTap,
  }) {
    return Obx(() {
      final t = selected.value;
      final txt = t != null ? t.format(context) : 'Pilih Jam';
      return InkWell(
        onTap: () => onTap(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.access_time, color: Colors.blueGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.blueGrey),
            ),
          ),
          child: Text(txt, style: TextStyle(fontSize: 16.sp)),
        ),
      );
    });
  }
}
