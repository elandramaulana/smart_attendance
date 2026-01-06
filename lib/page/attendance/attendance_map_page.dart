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
          // Cache status button
          Obx(() {
            final isSlowConnection = controller.isSlowConnection.value;
            return IconButton(
              icon: Icon(
                isSlowConnection ? Icons.cloud_off : Icons.cloud_done,
                color: isSlowConnection ? Colors.orange : Colors.white,
                size: 24.sp,
              ),
              onPressed: () => _showCacheDialog(context, controller),
            );
          }),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text('Memuat lokasi...'),
                SizedBox(height: 8.h),
                // Cache status indicator
                Obx(() => Text(
                      controller.cacheStatus.value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          );
        }

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: companyLoc,
                initialZoom: 16.0,
                maxZoom: 18.0,
                minZoom: 5.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.smart_attendance',
                  maxZoom: 18,
                  tileProvider: NetworkTileProvider(),
                  maxNativeZoom: 16,
                  tileBuilder: (context, tileWidget, tile) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      child: tileWidget,
                    );
                  },
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: companyLoc,
                      color: Colors.blue.withOpacity(0.15),
                      borderStrokeWidth: 1.5,
                      borderColor: Colors.blue,
                      radius: controller.geofenceRadius,
                      useRadiusInMeter: true,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 35,
                      height: 35,
                      point: userLoc,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Marker(
                      width: 35,
                      height: 35,
                      point: companyLoc,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Loading indicator overlay untuk tiles
            Obx(() {
              if (controller.isMapLoading.value) {
                return Container(
                  color: Colors.white.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text('Memuat peta...'),
                        SizedBox(height: 8.h),
                        Obx(() => Text(
                              controller.cacheStatus.value,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      }),
      bottomSheet: Obx(() {
        final address = controller.currentAddress.value;
        final canIn = controller.canClockIn;
        // final canBreak = controller.canBreak;
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
                // Address container
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
                SizedBox(height: 16.h),

                // Connection and Cache Status
                _buildStatusIndicators(controller),

                SizedBox(height: 20.h),

                // Action buttons
                Row(
                  children: [
                    // MASUK
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onPressed: canIn
                            ? () {
                                print('=== MASUK BUTTON PRESSED ===');
                                print('canIn: $canIn');
                                controller.takePhotoAndRecord('in');
                              }
                            : null,
                        icon: Icons.login_rounded,
                        label: "Masuk",
                        color: Colors.blue.shade700,
                        isEnabled: canIn,
                      ),
                    ),

                    SizedBox(width: 14.w),

                    // KELUAR
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onPressed: canOut
                            ? () {
                                print('=== KELUAR BUTTON PRESSED ===');
                                print('canOut: $canOut');
                                controller.takePhotoAndRecord('out');
                              }
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

  // Status indicators untuk connection dan cache
  Widget _buildStatusIndicators(MapAttendanceController controller) {
    return Obx(() {
      final isSlowConnection = controller.isSlowConnection.value;
      final cacheStatus = controller.cacheStatus.value;

      if (!isSlowConnection && cacheStatus.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          // Connection status
          if (isSlowConnection)
            Container(
              padding: EdgeInsets.all(10.w),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.signal_wifi_bad,
                      color: Colors.orange, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Koneksi lambat - Mode cache diaktifkan',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Cache status
          if (cacheStatus.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.storage, color: Colors.blue, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      cacheStatus,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  // Cache management button
                  InkWell(
                    onTap: () => _showCacheDialog(Get.context!, controller),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.settings,
                        size: 14.sp,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  // Dialog untuk cache management
  void _showCacheDialog(
      BuildContext context, MapAttendanceController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.storage, color: Colors.blue),
            SizedBox(width: 8.w),
            Text('Cache'),
          ],
        ),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCacheInfoRow(
                  'Connection Status:',
                  controller.isSlowConnection.value ? 'Slow/Offline' : 'Normal',
                  controller.isSlowConnection.value
                      ? Colors.orange
                      : Colors.green,
                ),
                SizedBox(height: 8.h),
                _buildCacheInfoRow(
                  'Cache Status:',
                  controller.cacheStatus.value.isNotEmpty
                      ? controller.cacheStatus.value
                      : 'No cache info',
                  Colors.blue,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Cache membantu menghemat data dan mempercepat loading saat koneksi lambat.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            )),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.refreshLocation();
            },
            child: Text('Refresh Data'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showClearCacheConfirmation(context, controller);
            },
            child: Text('Clear Cache', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheInfoRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12.sp, color: color),
          ),
        ),
      ],
    );
  }

  void _showClearCacheConfirmation(
      BuildContext context, MapAttendanceController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache'),
        content: Text(
            'Menghapus cache akan memaksa aplikasi mengambil data terbaru dari server. '
            'Lakukan ini jika ada masalah dengan data yang ditampilkan.\n\n'
            'Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
        elevation: 0,
      ),
    ),
  );
}
