import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_attendance/controller/map_attendance_controller.dart';

class AttendanceMapPage extends StatelessWidget {
  const AttendanceMapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color blueGray = Color(0xFF607D8B);
    const Color blueGrayLight = Color(0xFFCFD8DC);
    const Color blueGrayDark = Color(0xFF455A64);

    final controller = Get.put(MapAttendanceController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: blueGray,
        title: Text(
          'Lokasi Kehadiran',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 24.sp),
            onPressed: () => controller.refreshLocation(),
          ),
        ],
      ),
      body: Obx(() {
        final userLoc = controller.currentLocation.value;
        final companyLoc = controller.companyLocation.value;

        if (userLoc == null || companyLoc == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: companyLoc,
            initialZoom: 16.0,
            maxZoom: 18.0,
            minZoom: 5.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.smart_attendance',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: companyLoc,
                  color: Colors.blue.withOpacity(0.2),
                  borderStrokeWidth: 2,
                  borderColor: Colors.blue,
                  radius: controller.geofenceRadius,
                  useRadiusInMeter: true,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: userLoc,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.green,
                    size: 35,
                  ),
                ),
                Marker(
                  width: 40,
                  height: 40,
                  point: companyLoc,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
      bottomSheet: Obx(() {
        final address = controller.currentAddress.value;
        final canIn = controller.canClockIn;
        final canBreak = controller.canBreak;
        final canOut = controller.canClockOut;

        return SafeArea(
          bottom: true,
          top: false,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20.w,
              20.h,
              20.w,
              MediaQuery.of(context).viewPadding.bottom + 24.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: blueGrayDark.withOpacity(0.2),
                  blurRadius: 15.r,
                  offset: Offset(0, -3.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: blueGrayLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: blueGrayLight),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pin_drop, color: blueGray, size: 20.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: blueGrayDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    // MASUK
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onPressed: canIn
                            ? () => controller.takePhotoAndRecord('in')
                            : null,
                        icon: Icons.login_rounded,
                        label: "Masuk",
                        color: Colors.blue.shade700,
                        isEnabled: canIn,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // KEMBALI
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onPressed: canBreak
                            ? () => controller.takePhotoAndRecord('break')
                            : null,
                        icon: Icons.keyboard_return_rounded,
                        label: "Break",
                        color: Colors.amber.shade800,
                        isEnabled: canBreak,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // KELUAR
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onPressed: canOut
                            ? () => controller.takePhotoAndRecord('out')
                            : null,
                        icon: Icons.logout_rounded,
                        label: "Keluar",
                        color: Colors.red.shade700,
                        isEnabled: canOut,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

Widget _buildActionButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required IconData icon,
  required String label,
  required Color color,
  required bool isEnabled,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20.sp),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : color.withOpacity(0.4),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        elevation: 0, // Removing elevation since we're using custom shadow
      ),
    ),
  );
}
