import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:smart_attendance/controller/map_attendance_controller.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late MapAttendanceController _attendanceController;

  static const Color blueGray = Color(0xFF607D8B);
  static const Color blueGrayLight = Color(0xFFCFD8DC);
  static const Color blueGrayDark = Color(0xFF455A64);

  @override
  void initState() {
    super.initState();
    _attendanceController = Get.find<MapAttendanceController>();
    ever(_attendanceController.currentLocation, (loc) {
      if (loc != null) _animatedMapMove(loc, 16.0);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng dest, double zoom) {
    try {
      final latTween = Tween<double>(
          begin: _mapController.camera.center.latitude, end: dest.latitude);
      final lngTween = Tween<double>(
          begin: _mapController.camera.center.longitude, end: dest.longitude);
      final zoomTween =
          Tween<double>(begin: _mapController.camera.zoom, end: zoom);

      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      final animation =
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

      controller.addListener(() {
        try {
          _mapController.move(
            LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
            zoomTween.evaluate(animation),
          );
        } catch (_) {
          controller.dispose();
        }
      });
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          controller.dispose();
        }
      });
      controller.forward();
    } catch (_) {
      try {
        _mapController.move(dest, zoom);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = _attendanceController.currentLocation.value;
      final isLoading = _attendanceController.isLoading.value;

      if (current == null) {
        return Container(
          color: blueGrayLight.withOpacity(0.3),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: blueGray,
                  strokeWidth: 3.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Memuat peta lokasi...',
                  style: TextStyle(
                    color: blueGrayDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: current,
              initialZoom: 16.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              backgroundColor: blueGrayLight.withOpacity(0.3),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
                tileDisplay: const TileDisplay.fadeIn(),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 120.w,
                    height: 120.w,
                    point: current,
                    alignment: Alignment.center,
                    child: _buildUserLocationMarker(),
                  ),
                ],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: current,
                    color: blueGray.withOpacity(0.2),
                    borderColor: blueGray.withOpacity(0.7),
                    borderStrokeWidth: 2.w,
                    radius: 100, // remains meters
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 140.h,
            right: 16.w,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    if (current != null) _animatedMapMove(current, 16.0);
                  },
                  tooltip: 'Center Map',
                ),
                SizedBox(height: 8.h),
                _buildMapControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    final z = _mapController.camera.zoom;
                    if (z < 18)
                      _mapController.move(_mapController.camera.center, z + 1);
                  },
                  tooltip: 'Zoom In',
                ),
                SizedBox(height: 8.h),
                _buildMapControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final z = _mapController.camera.zoom;
                    if (z > 5)
                      _mapController.move(_mapController.camera.center, z - 1);
                  },
                  tooltip: 'Zoom Out',
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.r,
                          offset: Offset(0, 5.h),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: blueGray),
                        SizedBox(height: 16.h),
                        Text(
                          'Memperbarui lokasi...',
                          style: TextStyle(
                            color: blueGrayDark,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: blueGray.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: blueGray.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: blueGray, width: 3.w),
            boxShadow: [
              BoxShadow(
                color: blueGrayDark.withOpacity(0.3),
                blurRadius: 8.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Text(
              'Lokasi Anda',
              style: TextStyle(
                color: blueGrayDark,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: blueGray, size: 20.sp),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        style: IconButton.styleFrom(shape: const CircleBorder()),
      ),
    );
  }
}
