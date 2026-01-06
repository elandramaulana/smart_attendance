// lib/controller/map_attendance_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  var isMapLoading = true.obs;
  var isSlowConnection = false.obs;
  var companyName = "".obs;
  var companyAddress = "".obs;
  var companyLocation = Rxn<LatLng>();
  var cacheStatus = "".obs; // Status cache untuk debugging
  final double geofenceRadius = 100.0;

  // Cache Management
  static const int CACHE_DURATION_HOURS = 24;
  static const int GEOCODING_CACHE_DURATION_HOURS = 72;
  static const int COMPANY_DATA_CACHE_DURATION_HOURS = 168; // 1 week

  // In-memory cache
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  final MapAttendanceService _mapService = MapAttendanceService();
  final LocationService _locationService = LocationService();
  final AttendanceService _attService = AttendanceService();
  final HomeController homeController = Get.find<HomeController>();

  Timer? _timestampTimer;
  Timer? _connectionTimer;
  Timer? _cacheCleanupTimer;
  final ImagePicker _picker = ImagePicker();

  final Rxn<String> lastSession = Rxn<String>();
  var todayAtt = Rxn<AttendanceTodayModel>();

  @override
  void onInit() {
    super.onInit();
    _initializeCacheSystem();
    _checkConnectionSpeed();
    getPath();
    _loadLocationAndAddress();
    _initTimestamp();
    _loadDataWithPriority();
    _setupCacheCleanup();
  }

  @override
  void onClose() {
    _timestampTimer?.cancel();
    _connectionTimer?.cancel();
    _cacheCleanupTimer?.cancel();
    super.onClose();
  }

  // ========== CACHE MANAGEMENT SYSTEM ==========

  void _initializeCacheSystem() {
    cacheStatus.value = "Initializing cache...";
    _loadMemoryCacheFromStorage();
  }

  void _setupCacheCleanup() {
    // Cleanup cache setiap 6 jam
    _cacheCleanupTimer = Timer.periodic(Duration(hours: 6), (_) {
      _cleanupExpiredCache();
    });
  }

  Future<void> _loadMemoryCacheFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString('memory_cache');
      final timestampData = prefs.getString('cache_timestamps');

      if (cacheData != null && timestampData != null) {
        final cache = jsonDecode(cacheData) as Map<String, dynamic>;
        final timestamps = jsonDecode(timestampData) as Map<String, dynamic>;

        _memoryCache.addAll(cache);
        timestamps.forEach((key, value) {
          _cacheTimestamps[key] = DateTime.parse(value);
        });

        cacheStatus.value = "Cache loaded: ${_memoryCache.length} items";
      }
    } catch (e) {
      cacheStatus.value = "Cache init failed: $e";
    }
  }

  Future<void> _saveMemoryCacheToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert timestamps to strings
      final timestampStrings = <String, String>{};
      _cacheTimestamps.forEach((key, value) {
        timestampStrings[key] = value.toIso8601String();
      });

      await prefs.setString('memory_cache', jsonEncode(_memoryCache));
      await prefs.setString('cache_timestamps', jsonEncode(timestampStrings));
    } catch (e) {
      print('Failed to save cache: $e');
    }
  }

  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp).inHours > CACHE_DURATION_HOURS) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _saveMemoryCacheToStorage();
      cacheStatus.value = "Cleaned ${expiredKeys.length} expired items";
    }
  }

  T? _getCachedData<T>(String key, int maxAgeHours) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    final age = DateTime.now().difference(timestamp);
    if (age.inHours > maxAgeHours) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _memoryCache[key] as T?;
  }

  void _setCachedData<T>(String key, T data) {
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    _saveMemoryCacheToStorage();
  }

  // ========== CONNECTION OPTIMIZATION ==========

  Future<void> _checkConnectionSpeed() async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http
          .get(Uri.parse('https://www.google.com/generate_204'))
          .timeout(Duration(seconds: 3));

      stopwatch.stop();
      isSlowConnection.value = stopwatch.elapsedMilliseconds > 2000;

      if (isSlowConnection.value) {
        cacheStatus.value = "Slow connection detected - Cache priority mode";
      }
    } catch (e) {
      isSlowConnection.value = true;
      cacheStatus.value = "No connection - Offline cache mode";
    }
  }

  // ========== DATA LOADING WITH CACHE PRIORITY ==========

  Future<void> _loadDataWithPriority() async {
    if (isSlowConnection.value) {
      // Mode koneksi lambat: prioritas cache
      await _loadFromCacheFirst();

      // Background refresh jika memungkinkan
      Future.delayed(Duration(seconds: 2), () {
        _backgroundRefresh();
      });
    } else {
      // Mode koneksi normal
      await Future.wait([
        fetchCompanyDataWithCache(),
        fetchTodayAttendanceWithCache(),
      ]);
    }

    isMapLoading.value = false;
  }

  Future<void> _loadFromCacheFirst() async {
    // Load company data dari cache
    final cachedCompany = _getCachedData<Map<String, dynamic>>(
        'company_data', COMPANY_DATA_CACHE_DURATION_HOURS);

    if (cachedCompany != null) {
      companyName.value = cachedCompany['namaCompany'] ?? '';
      companyAddress.value = cachedCompany['alamat'] ?? '';
      companyLocation.value = LatLng(
        cachedCompany['latitude']?.toDouble() ?? 0.0,
        cachedCompany['longitude']?.toDouble() ?? 0.0,
      );
      cacheStatus.value = "Using cached company data";
    }

    // Load attendance data dari cache
    final cachedAttendance = _getCachedData<Map<String, dynamic>>(
        'today_attendance', 2 // Cache attendance hanya 2 jam
        );

    if (cachedAttendance != null) {
      // Reconstruct AttendanceTodayModel dari cache
      todayAtt.value = AttendanceTodayModel.fromJson(cachedAttendance);
      _updateLastSession();
      cacheStatus.value = "Using cached attendance data";
    }
  }

  Future<void> _backgroundRefresh() async {
    try {
      // Refresh data di background tanpa loading indicator
      await Future.wait([
        fetchCompanyDataWithCache(),
        fetchTodayAttendanceWithCache(),
      ]);
      cacheStatus.value = "Background refresh completed";
    } catch (e) {
      cacheStatus.value = "Background refresh failed: offline mode";
    }
  }

  // ========== COMPANY DATA WITH CACHE ==========

  Future<void> fetchCompanyDataWithCache() async {
    try {
      final cacheKey = 'company_data';

      // Coba ambil dari cache dulu
      final cachedData = _getCachedData<Map<String, dynamic>>(
          cacheKey, COMPANY_DATA_CACHE_DURATION_HOURS);

      if (cachedData != null && isSlowConnection.value) {
        // Gunakan cache jika koneksi lambat
        companyName.value = cachedData['namaCompany'] ?? '';
        companyAddress.value = cachedData['alamat'] ?? '';
        companyLocation.value = LatLng(
          cachedData['latitude']?.toDouble() ?? 0.0,
          cachedData['longitude']?.toDouble() ?? 0.0,
        );
        return;
      }

      // Fetch dari server
      final data = await _mapService
          .getMapAttendance()
          .timeout(Duration(seconds: isSlowConnection.value ? 20 : 10));

      // Update UI
      companyName.value = data.namaCompany;
      companyAddress.value = data.alamat;
      companyLocation.value = LatLng(data.latitude, data.longitude);

      // Cache data
      _setCachedData(cacheKey, {
        'namaCompany': data.namaCompany,
        'alamat': data.alamat,
        'latitude': data.latitude,
        'longitude': data.longitude,
      });

      cacheStatus.value = "Company data refreshed and cached";
    } catch (e) {
      // Jika gagal fetch dan ada cache, gunakan cache
      final cachedData = _getCachedData<Map<String, dynamic>>('company_data',
          COMPANY_DATA_CACHE_DURATION_HOURS * 2 // Extended cache untuk error
          );

      if (cachedData != null) {
        companyName.value = cachedData['namaCompany'] ?? '';
        companyAddress.value = cachedData['alamat'] ?? '';
        companyLocation.value = LatLng(
          cachedData['latitude']?.toDouble() ?? 0.0,
          cachedData['longitude']?.toDouble() ?? 0.0,
        );
        cacheStatus.value = "Using cached data (server error)";
      } else {
        Get.snackbar(
          "Peringatan",
          "Gagal memuat data perusahaan dan tidak ada cache tersedia",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }
  }

  // ========== ATTENDANCE DATA WITH CACHE ==========

  Future<void> fetchTodayAttendanceWithCache() async {
    try {
      final cacheKey = 'today_attendance';

      // Untuk attendance, cache lebih pendek (max 2 jam)
      final cachedData = _getCachedData<Map<String, dynamic>>(cacheKey, 2);

      if (cachedData != null && isSlowConnection.value) {
        todayAtt.value = AttendanceTodayModel.fromJson(cachedData);
        _updateLastSession();
        return;
      }

      // Fetch dari server
      final today = await _attService
          .getTodayAttendance()
          .timeout(Duration(seconds: isSlowConnection.value ? 20 : 10));

      // Update UI
      todayAtt.value = today;
      _updateLastSession();

      // Cache data (convert to JSON)
      _setCachedData(cacheKey, today.toJson());
      cacheStatus.value = "Attendance data refreshed and cached";
    } catch (e) {
      // Fallback ke cache jika ada
      final cachedData = _getCachedData<Map<String, dynamic>>(
          'today_attendance', 12 // Extended cache untuk error (12 jam)
          );

      if (cachedData != null) {
        todayAtt.value = AttendanceTodayModel.fromJson(cachedData);
        _updateLastSession();
        cacheStatus.value = "Using cached attendance (server error)";
      }
    }
  }

  void _updateLastSession() {
    final att = todayAtt.value;
    if (att == null) return;

    if (!att.hasCheckedIn) {
      lastSession.value = null;
    } else if (att.hasCheckedIn && !att.hasCheckedOut) {
      lastSession.value = 'in';
    } else {
      lastSession.value = 'out';
    }
  }

  // ========== GEOCODING WITH CACHE ==========

  Future<void> _getAddressFromLatLng(LatLng loc) async {
    final cacheKey =
        'geocoding_${loc.latitude.toStringAsFixed(4)}_${loc.longitude.toStringAsFixed(4)}';

    // Cek cache geocoding
    final cachedAddress =
        _getCachedData<String>(cacheKey, GEOCODING_CACHE_DURATION_HOURS);

    if (cachedAddress != null) {
      currentAddress.value = cachedAddress;
      cacheStatus.value = "Using cached address";
      return;
    }

    try {
      final placemarks =
          await placemarkFromCoordinates(loc.latitude, loc.longitude)
              .timeout(Duration(seconds: isSlowConnection.value ? 8 : 10));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if (p.name?.isNotEmpty == true) p.name!,
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.country?.isNotEmpty == true) p.country!,
        ].join(', ');

        currentAddress.value = address;

        // Cache alamat
        _setCachedData(cacheKey, address);
        cacheStatus.value = "Address geocoded and cached";
      }
    } catch (e) {
      // Fallback ke koordinat
      final fallbackAddress = "Lat: ${loc.latitude.toStringAsFixed(6)}, "
          "Lng: ${loc.longitude.toStringAsFixed(6)}";
      currentAddress.value = fallbackAddress;

      // Cache koordinat sebagai fallback
      _setCachedData(cacheKey, fallbackAddress);
    }
  }

  // ========== EXISTING METHODS (UPDATED) ==========

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

      // Refresh data juga
      if (!isSlowConnection.value) {
        await Future.wait([
          fetchCompanyDataWithCache(),
          fetchTodayAttendanceWithCache(),
        ]);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadLocationAndAddress() async {
    try {
      final pos = await _locationService.determinePosition();
      final loc = LatLng(pos.latitude, pos.longitude);
      currentLocation.value = loc;

      await _getAddressFromLatLng(loc);
    } catch (e) {
      currentAddress.value = "Lokasi tidak tersedia";
    }
  }

  // Method untuk clear cache manual
  Future<void> clearCache() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('memory_cache');
    await prefs.remove('cache_timestamps');

    cacheStatus.value = "Cache cleared";

    Get.snackbar(
      "Cache Cleared",
      "Semua cache telah dihapus. Data akan direfresh.",
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

    // Refresh data
    await _loadDataWithPriority();
  }

  // Alias methods untuk compatibility
  Future<void> fetchCompanyData() => fetchCompanyDataWithCache();
  Future<void> fetchTodayAttendance() => fetchTodayAttendanceWithCache();

  Future<void> takePhotoAndRecord(String type) async {
    print('=== START takePhotoAndRecord ===');
    print('Type: $type');
    print('Current Location: ${currentLocation.value}');

    if (currentLocation.value == null) {
      print('ERROR: Lokasi null');
      Get.snackbar("Gagal", "Lokasi belum tersedia.",
          backgroundColor: const Color(0xFFCFD8DC));
      return;
    }

    // PERBAIKAN: Kurangi ukuran gambar untuk menghindari 403
    final imageQuality =
        isSlowConnection.value ? 30 : 50; // Turunkan dari 50:80 ke 30:50
    final maxSize =
        isSlowConnection.value ? 400 : 800; // Turunkan dari 600:1200 ke 400:800

    print('Image Quality: $imageQuality, Max Size: $maxSize');
    print('Is Slow Connection: ${isSlowConnection.value}');

    print('Opening camera...');
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: imageQuality,
      maxWidth: maxSize.toDouble(),
      maxHeight: maxSize.toDouble(),
    );

    if (photo == null) {
      print('ERROR: Photo is null (user cancelled or camera failed)');
      return;
    }
    print('Photo captured: ${photo.path}');

    if (isSlowConnection.value) {
      print('Showing slow connection dialog...');
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengirim data...'),
                  Text('Mohon tunggu karena koneksi lambat'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }

    try {
      print('Reading photo bytes...');
      final bytes = await File(photo.path).readAsBytes();
      print(
          'Photo size BEFORE compression: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(2)} KB)');

      // PERBAIKAN: Kompresi lebih lanjut jika masih terlalu besar
      var finalBytes = bytes;
      if (bytes.length > 100000) {
        // Jika > 100KB
        print('Compressing image further...');
        final img.Image? image = img.decodeImage(bytes);
        if (image != null) {
          // Resize lebih kecil lagi jika perlu
          final resized = img.copyResize(image, width: 600);
          finalBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 40));
          print(
              'Photo size AFTER compression: ${finalBytes.length} bytes (${(finalBytes.length / 1024).toStringAsFixed(2)} KB)');
        }
      }

      print('Converting to base64...');
      final dataUri = 'data:image/jpeg;base64,${base64Encode(finalBytes)}';
      print('Base64 length: ${dataUri.length} characters');
      print(
          'Estimated payload size: ${(dataUri.length / 1024).toStringAsFixed(2)} KB');

      final now = DateTime.now();
      print('Current time: $now');

      final rec = AttendanceModel(
        attSession: type,
        time: DateFormat('HH:mm:ss').format(now),
        note: '',
        latitude: currentLocation.value!.latitude,
        longitude: currentLocation.value!.longitude,
        selfie: dataUri,
      );

      print('Attendance Record Created:');
      print('  - Session: ${rec.attSession}');
      print('  - Time: ${rec.time}');
      print('  - Lat: ${rec.latitude}');
      print('  - Long: ${rec.longitude}');
      print('  - Selfie length: ${rec.selfie?.length ?? 0}');

      print('Sending to API...');
      final timeout =
          Duration(seconds: isSlowConnection.value ? 60 : 30); // Tambah timeout
      print('Timeout: ${timeout.inSeconds}s');

      await _attService.recordAttendance(rec).timeout(timeout);

      print('API call successful!');

      // Refresh data dan clear cache attendance
      print('Clearing cache...');
      _memoryCache.remove('today_attendance');
      _cacheTimestamps.remove('today_attendance');

      print('Fetching today attendance...');
      await fetchTodayAttendanceWithCache();

      print('Fetching home controller attendance...');
      await homeController.fetchTodayAttendance();

      await Future.delayed(Duration(milliseconds: 300));

      if (isSlowConnection.value) {
        print('Closing slow connection dialog...');
        Get.back();
      }

      print('Showing success snackbar...');
      Get.snackbar(
        "Berhasil",
        "Anda berhasil '$type' pada ${DateFormat('HH:mm').format(now)}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('Navigating to bottomNav...');
      Get.offAllNamed(AppRoutes.bottomNav);

      print('Updating home controller...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeController.update();
      });

      print('=== END takePhotoAndRecord SUCCESS ===');
    } catch (e, stackTrace) {
      print('=== ERROR in takePhotoAndRecord ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');

      if (isSlowConnection.value) {
        print('Closing slow connection dialog after error...');
        Get.back();
      }

      // PERBAIKAN: Pesan error yang lebih informatif
      String errorMessage = "Tidak dapat merekam kehadiran";
      if (e.toString().contains('403')) {
        errorMessage = "Gagal mengirim data. Coba lagi atau hubungi admin.";
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
      }

      Get.snackbar(
        "Gagal",
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );

      print('=== END takePhotoAndRecord ERROR ===');
    }
  }

  // bool get canClockIn => isWithinGeofence && todayAtt.value?.inTime != null;
  // bool get canClockOut => isWithinGeofence && todayAtt.value?.inTime != null;

  // yang betul
  bool get canClockIn => isWithinGeofence && todayAtt.value?.inTime == null;
  bool get canClockOut =>
      isWithinGeofence &&
      todayAtt.value?.inTime != null &&
      todayAtt.value?.outTime == null;
}
