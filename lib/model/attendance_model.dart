class AttendanceModel {
  final String attSession;
  final String time;
  final String note;
  final double latitude;
  final double longitude;
  final String selfie;

  AttendanceModel({
    required this.attSession,
    required this.time,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.selfie,
  });

  /// Konversi ke Map untuk dikirim sebagai form-data
  Map<String, String> toJson() {
    return {
      'att_session': attSession,
      'time': time,
      'note': note,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'selfie': selfie,
    };
  }
}
