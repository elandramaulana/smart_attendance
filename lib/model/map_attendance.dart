class MapAttendance {
  final String namaCompany;
  final String alamat;
  final double latitude;
  final double longitude;

  MapAttendance({
    required this.namaCompany,
    required this.alamat,
    required this.latitude,
    required this.longitude,
  });

  factory MapAttendance.fromJson(Map<String, dynamic> json) {
    return MapAttendance(
      namaCompany: json['nama_company'] as String,
      alamat: json['alamat'] as String,
      latitude: double.parse(json['latitude'] as String),
      longitude: double.parse(json['longitude'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_company': namaCompany,
      'alamat': alamat,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
  }
}
