import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/cuti_form_controller.dart';
import 'package:smart_attendance/utils/text_formatter_helper.dart';

class FormCutiPage extends GetView<CutiFormController> {
  const FormCutiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Form Pengajuan Cuti',
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
                      title: const Text("Sertakan Lampiran"),
                      value: true,
                      groupValue: controller.isWithLampiran.value,
                      onChanged: (val) {
                        if (val != null) {
                          controller.isWithLampiran.value = val;
                          // Jika berpindah ke opsi tanpa surat, kita bersihkan file (jika sempat ada)
                          if (!val) {
                            controller.pickedFile.value = null;
                          }
                        }
                      },
                    ),
                    // Opsi: Sakit tanpa surat
                    RadioListTile<bool>(
                      title: const Text("Tanpa Lampiran"),
                      value: false,
                      groupValue: controller.isWithLampiran.value,
                      onChanged: (val) {
                        if (val != null) {
                          controller.isWithLampiran.value = val;
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

              SizedBox(height: 10.h),

              // Jenis Cuti
              DropdownButtonFormField<String>(
                value: controller.selectedJenisLeave.value.isEmpty
                    ? null
                    : controller.selectedJenisLeave.value,
                items: controller.jenisLeaveOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child:
                              Text(TextFormatterHelper.formatLeaveType(option)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedJenisLeave.value = value;
                  }
                },
                decoration: InputDecoration(
                  labelText: "Jenis Cuti",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Pilih jenis cuti";
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Tanggal Mulai
              TextFormField(
                controller: controller.startDateController,
                readOnly: true,
                onTap: () => controller.pickDate(
                    context, controller.startDateController),
                decoration: InputDecoration(
                  labelText: "Tanggal Mulai",
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.blueGrey),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Pilih tanggal mulai" : null,
              ),
              SizedBox(height: 16.h),

              // Tanggal Selesai
              TextFormField(
                controller: controller.endDateController,
                readOnly: true,
                onTap: () =>
                    controller.pickDate(context, controller.endDateController),
                decoration: InputDecoration(
                  labelText: "Tanggal Selesai",
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.blueGrey),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Pilih tanggal selesai" : null,
              ),
              SizedBox(height: 16.h),

              // Alasan
              TextFormField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: "Alasan Pengajuan",
                  hintText: "Tuliskan alasan pengajuan cuti",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.blueGrey),
                  ),
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? "Masukkan alasan" : null,
              ),
              SizedBox(height: 24.h),

              Obx(() {
                if (!controller.isWithLampiran.value) {
                  // Jika user memilih "tanpa surat", tidak tampilkan apapun
                  return const SizedBox.shrink();
                }
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

              // Tombol Submit
              Obx(() {
                final isLoading = controller.isSubmitting.value;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoading ? Colors.grey : Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  onPressed: isLoading ? null : controller.submitForm,
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            const Text(
                              "Mengirim...",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : const Text(
                          "Ajukan Cuti",
                          style: TextStyle(color: Colors.white),
                        ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
