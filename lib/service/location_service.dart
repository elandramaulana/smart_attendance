import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi aktif.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Layanan lokasi tidak aktif. Silahkan aktifkan lokasi.");
    }

    // Periksa permission lokasi.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Permission lokasi ditolak.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Permission lokasi ditolak secara permanen, silahkan ubah pengaturan di device Anda.");
    }

    return await Geolocator.getCurrentPosition();
  }
}
