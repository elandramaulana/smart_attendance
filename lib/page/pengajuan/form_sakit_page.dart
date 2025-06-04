import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/sakit_form_controller.dart';

class FormSakitPage extends StatelessWidget {
  final SakitFormController controller = Get.put(SakitFormController());

  FormSakitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Form Pengajuan Sakit',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              // === 1. Pilihan Radio: Dengan Surat Dokter / Tanpa Surat ===
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tipe Pengajuan:",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Opsi: Sakit dengan surat dokter
                    RadioListTile<bool>(
                      title: const Text("Sakit dengan surat dokter"),
                      value: true,
                      groupValue: controller.isWithDoctorNote.value,
                      onChanged: (val) {
                        if (val != null) {
                          controller.isWithDoctorNote.value = val;
                          // Jika berpindah ke opsi tanpa surat, kita bersihkan file (jika sempat ada)
                          if (!val) {
                            controller.pickedFile.value = null;
                          }
                        }
                      },
                    ),
                    // Opsi: Sakit tanpa surat
                    RadioListTile<bool>(
                      title: const Text("Sakit tanpa surat"),
                      value: false,
                      groupValue: controller.isWithDoctorNote.value,
                      onChanged: (val) {
                        if (val != null) {
                          controller.isWithDoctorNote.value = val;
                          // Jika tanpa surat, pastikan tidak ada file tersisa
                          if (!val) {
                            controller.pickedFile.value = null;
                          }
                        }
                      },
                    ),
                  ],
                );
              }),

              SizedBox(height: 16.h),

              // === 2. Tanggal Mulai ===
              TextFormField(
                controller: controller.startDateController,
                readOnly: true,
                onTap: () => controller.pickDate(
                    context, controller.startDateController),
                decoration: InputDecoration(
                  labelText: "Tanggal Mulai",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Pilih tanggal mulai" : null,
              ),
              SizedBox(height: 16.h),

              // === 3. Tanggal Selesai ===
              TextFormField(
                controller: controller.endDateController,
                readOnly: true,
                onTap: () =>
                    controller.pickDate(context, controller.endDateController),
                decoration: InputDecoration(
                  labelText: "Tanggal Selesai",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Pilih tanggal selesai" : null,
              ),
              SizedBox(height: 16.h),

              // === 4. Alasan Sakit ===
              TextFormField(
                controller: controller.reasonController,
                decoration: InputDecoration(
                  labelText: "Alasan Sakit",
                  hintText: "Tuliskan keluhan",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Masukkan alasan sakit" : null,
              ),
              SizedBox(height: 16.h),

              // === 5. Lampiran PDF (Hanya muncul jika isWithDoctorNote == true) ===
              Obx(() {
                if (!controller.isWithDoctorNote.value) {
                  // Jika user memilih "tanpa surat", tidak tampilkan apapun
                  return const SizedBox.shrink();
                }

                // Jika user memilih "dengan surat dokter", tampilkan widget lampiran
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Lampiran PDF (Surat Dokter):",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton.icon(
                      onPressed: () => controller.pickPdf(),
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      label: const Text(
                        "Pilih PDF",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    Obx(() {
                      final file = controller.pickedFile.value;
                      return Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: file != null
                              ? Text(
                                  file.name,
                                  style: TextStyle(fontSize: 16.sp),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    size: 48.h,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                        ),
                      );
                    }),
                    SizedBox(height: 16.h),
                  ],
                );
              }),

              SizedBox(height: 24.h),

              // === 6. Tombol Submit ===
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                onPressed: controller.submitForm,
                child: const Text(
                  "Ajukan Sakit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
