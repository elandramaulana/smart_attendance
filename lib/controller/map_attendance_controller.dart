// lib/controller/map_attendance_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_attendance/controller/home_controller.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/attendance_model.dart';
import 'package:smart_attendance/model/attendance_today_model.dart';
import 'package:smart_attendance/service/location_service.dart';
import 'package:smart_attendance/service/map_attendance_service.dart';
import 'package:smart_attendance/service/attendance_service.dart';

class MapAttendanceController extends GetxController {
  var currentAddress = "Mendapatkan lokasi...".obs;
  var currentTimestamp = "".obs;
  var currentLocation = Rxn<LatLng>();
  var isLoading = false.obs;
  var companyName = "".obs;
  var companyAddress = "".obs;
  var companyLocation = Rxn<LatLng>();
  final double geofenceRadius = 100.0;

  final MapAttendanceService _mapService = MapAttendanceService();
  final LocationService _locationService = LocationService();
  final AttendanceService _attService = AttendanceService();
  final HomeController homeController = Get.find<HomeController>();

  Timer? _timestampTimer;
  final ImagePicker _picker = ImagePicker();

  final Rxn<String> lastSession = Rxn<String>();
  var todayAtt = Rxn<AttendanceTodayModel>();

  @override
  void onInit() {
    super.onInit();
    getPath();
    _loadLocationAndAddress();
    _initTimestamp();
    fetchCompanyData();
    fetchTodayAttendance();
  }

  @override
  void onClose() {
    _timestampTimer?.cancel();
    super.onClose();
  }

  void _initTimestamp() {
    _updateTimestamp();
    _timestampTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateTimestamp();
    });
  }

  void _updateTimestamp() {
    final now = DateTime.now();
    currentTimestamp.value =
        DateFormat('EEEE, dd MMM yyyy • HH:mm').format(now);
  }

  Future<String> getPath() async {
    final cacheDirectory = await getTemporaryDirectory();
    return cacheDirectory.path;
  }

  bool get isWithinGeofence {
    final userLoc = currentLocation.value;
    final compLoc = companyLocation.value;
    if (userLoc == null || compLoc == null) return false;
    return Distance()
            .as(LengthUnit.Meter, userLoc, compLoc)
            .compareTo(geofenceRadius) <=
        0;
  }

  Future<void> refreshLocation() async {
    if (isLoading.value) return;
    isLoading.value = true;
    currentAddress.value = "Memperbarui lokasi...";
    try {
      await _loadLocationAndAddress();
      _updateTimestamp();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadLocationAndAddress() async {
    final pos = await _locationService.determinePosition();
    final loc = LatLng(pos.latitude, pos.longitude);
    currentLocation.value = loc;
    await _getAddressFromLatLng(loc);
  }

  Future<void> _getAddressFromLatLng(LatLng loc) async {
    final placemarks =
        await placemarkFromCoordinates(loc.latitude, loc.longitude);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      currentAddress.value = [
        if (p.name?.isNotEmpty == true) p.name!,
        if (p.street?.isNotEmpty == true) p.street!,
        if (p.locality?.isNotEmpty == true) p.locality!,
        if (p.country?.isNotEmpty == true) p.country!,
      ].join(', ');
    }
  }

  Future<void> fetchCompanyData() async {
    final data = await _mapService.getMapAttendance();
    companyName.value = data.namaCompany;
    companyAddress.value = data.alamat;
    companyLocation.value = LatLng(data.latitude, data.longitude);
  }

  Future<void> fetchTodayAttendance() async {
    try {
      final today = await _attService.getTodayAttendance();
      todayAtt.value = today;

      if (!today.hasCheckedIn) {
        lastSession.value = null;
      } else if (today.hasCheckedIn && !today.hasOnBreak) {
        lastSession.value = 'in';
      } else if (today.hasOnBreak && !today.hasCheckedOut) {
        lastSession.value = 'break';
      } else {
        lastSession.value = 'out';
      }
    } catch (e) {
      print('Error fetchTodayAttendance: $e');
    }
  }

  Future<void> takePhotoAndRecord(String type) async {
    if (currentLocation.value == null) {
      Get.snackbar("Gagal", "Lokasi belum tersedia.",
          backgroundColor: const Color(0xFFCFD8DC));
      return;
    }

    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (photo == null) return;

    final bytes = await File(photo.path).readAsBytes();
    final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    final now = DateTime.now();

    final rec = AttendanceModel(
      attSession: type,
      time: DateFormat('HH:mm:ss').format(now),
      note: '',
      latitude: currentLocation.value!.latitude,
      longitude: currentLocation.value!.longitude,
      selfie: dataUri,
    );

    try {
      await _attService.recordAttendance(rec);
      await fetchTodayAttendance();
      await homeController.fetchTodayAttendance();

      // Add a delay to ensure data is loaded properly
      await Future.delayed(Duration(milliseconds: 300));

      Get.snackbar(
        "Berhasil",
        "Anda berhasil '$type' pada ${DateFormat('HH:mm').format(now)}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.bottomNav);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeController.update();
      });
    } catch (e) {
      Get.snackbar(
        "Gagal",
        "Tidak dapat merekam kehadiran: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool get canClockIn => isWithinGeofence && todayAtt.value?.inTime == null;
  bool get canBreak =>
      isWithinGeofence &&
      todayAtt.value?.inTime != null &&
      todayAtt.value?.breakTime == null;
  bool get canClockOut =>
      isWithinGeofence &&
      todayAtt.value?.breakTime != null &&
      todayAtt.value?.outTime == null;
}
