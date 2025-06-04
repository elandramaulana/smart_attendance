import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/controller/cuti_form_controller.dart';

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
              // Jenis Cuti
              DropdownButtonFormField<String>(
                value: controller.selectedJenisLeave.value.isEmpty
                    ? null
                    : controller.selectedJenisLeave.value,
                items: controller.jenisLeaveOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option
                                .split(' ')
                                .map((word) =>
                                    word[0].toUpperCase() + word.substring(1))
                                .join(' '),
                          ),
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

              // Tombol Submit
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                onPressed: controller.submitForm,
                child: const Text(
                  "Ajukan Cuti",
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
