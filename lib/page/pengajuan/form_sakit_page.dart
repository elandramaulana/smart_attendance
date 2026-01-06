import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/sakit_form_controller.dart';
import 'package:smart_attendance/utils/text_formatter_helper.dart';

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
              // === 1. Pilihan Radio: Jenis Sakit ===
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jenis Pengajuan Sakit:",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    RadioListTile<String>(
                      title: Text(
                          TextFormatterHelper.formatSickType('dengan_surat')),
                      value: 'dengan_surat',
                      groupValue: controller.selectedJenis.value,
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedJenis.value = val;
                          if (val == 'tanpa_surat') {
                            controller.pickedFile.value = null;
                            controller.fileBase64.value = '';
                          }
                        }
                      },
                    ),

// Opsi: Tanpa surat
                    RadioListTile<String>(
                      title: Text(
                          TextFormatterHelper.formatSickType('tanpa_surat')),
                      value: 'tanpa_surat',
                      groupValue: controller.selectedJenis.value,
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedJenis.value = val;
                          controller.pickedFile.value = null;
                          controller.fileBase64.value = '';
                        }
                      },
                    )
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

              // === 5. Lampiran PDF (Hanya muncul jika pilih "dengan_surat") ===
              Obx(() {
                // Hanya tampilkan jika user pilih "dengan_surat"
                if (controller.selectedJenis.value != 'dengan_surat') {
                  return const SizedBox.shrink();
                }

                // Tampilkan widget lampiran
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Lampiran PDF (Surat Dokter):",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "*wajib",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
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

                    SizedBox(height: 8.h),

                    // Preview file yang dipilih
                    Obx(() {
                      final file = controller.pickedFile.value;
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: file != null
                                ? Colors.green.shade300
                                : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          color: file != null
                              ? Colors.green.shade50
                              : Colors.grey.shade50,
                        ),
                        child: file != null
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 40.h,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          file.name,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${(file.size / 1024).toStringAsFixed(1)} KB',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      controller.pickedFile.value = null;
                                      controller.fileBase64.value = '';
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 48.h,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Belum ada file dipilih',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }),
                    SizedBox(height: 16.h),
                  ],
                );
              }),

              SizedBox(height: 24.h),

              // === 6. Tombol Submit ===
              Obx(() {
                final isSubmitting = controller.isSubmitting.value;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSubmitting ? Colors.grey : Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  onPressed: isSubmitting ? null : controller.submitForm,
                  child: isSubmitting
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
                          "Ajukan Sakit",
                          style: TextStyle(color: Colors.white),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
