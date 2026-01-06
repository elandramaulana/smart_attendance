class AttendanceModel {
  final String attSession;
  final String time;
  final String note;
  final double latitude;
  final double longitude;
  final String selfie; // Base64 string

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

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attSession: json['att_session'] ?? '',
      time: json['time'] ?? '',
      note: json['note'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      selfie: json['selfie'] ?? '',
    );
  }
}
