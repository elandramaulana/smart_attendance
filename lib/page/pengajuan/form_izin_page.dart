// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:smart_attendance/controller/izin_form_controller.dart';

// class FormIzinPage extends GetView<IzinFormController> {
//   const FormIzinPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme:
//             IconThemeData(color: Colors.white), // <-- semua ikon jadi putih
//         title: const Text(
//           'Form Pengajuan Sakit',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.blueGrey,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Form(
//           key: controller.formKey,
//           child: ListView(
//             children: [
//               // Tanggal Mulai
//               TextFormField(
//                 controller: controller.startDateController,
//                 readOnly: true,
//                 onTap: () => controller.pickDate(
//                     context, controller.startDateController),
//                 decoration: InputDecoration(
//                   labelText: "Tanggal Mulai",
//                   prefixIcon: const Icon(Icons.calendar_today),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 validator: (v) =>
//                     (v == null || v.isEmpty) ? "Pilih tanggal mulai" : null,
//               ),
//               SizedBox(height: 16.h),

//               // Tanggal Selesai
//               TextFormField(
//                 controller: controller.endDateController,
//                 readOnly: true,
//                 onTap: () =>
//                     controller.pickDate(context, controller.endDateController),
//                 decoration: InputDecoration(
//                   labelText: "Tanggal Selesai",
//                   prefixIcon: const Icon(Icons.calendar_today),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 validator: (v) =>
//                     (v == null || v.isEmpty) ? "Pilih tanggal selesai" : null,
//               ),
//               SizedBox(height: 16.h),

//               // Alasan
//               TextFormField(
//                 controller: controller.reasonController,
//                 decoration: InputDecoration(
//                   labelText: "Alasan Izin",
//                   hintText: "Tuliskan Alasan",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 maxLines: 3,
//                 validator: (v) =>
//                     (v == null || v.isEmpty) ? "Masukkan alasan izin" : null,
//               ),
//               SizedBox(height: 16.h),

//               // Lampiran PDF
//               Text("Lampiran PDF:",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8.h),
//               ElevatedButton.icon(
//                 onPressed: () => controller.pickPdf(),
//                 icon: const Icon(Icons.attach_file, color: Colors.white),
//                 label: const Text(
//                   "Pilih PDF",
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueGrey,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r)),
//                 ),
//               ),
//               Obx(() {
//                 final file = controller.pickedFile.value;
//                 return Padding(
//                   padding: EdgeInsets.only(top: 12.h),
//                   child: Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(8.w),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade400),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: file != null
//                         ? Text(
//                             file.name,
//                             style: TextStyle(fontSize: 16.sp),
//                           )
//                         : Center(
//                             child: Icon(
//                               Icons.picture_as_pdf,
//                               size: 48.h,
//                               color: Colors.grey.shade400,
//                             ),
//                           ),
//                   ),
//                 );
//               }),
//               SizedBox(height: 24.h),

//               // Submit
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueGrey,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r)),
//                   padding: EdgeInsets.symmetric(vertical: 16.h),
//                 ),
//                 onPressed: controller.submitForm,
//                 child: const Text(
//                   "Ajukan Izin",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
