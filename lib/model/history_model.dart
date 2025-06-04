// lib/model/history_model.dart

class History {
  final int id;
  final String name;
  final DateTime date;
  final String? inTime;
  final String? inStatus;
  final String? inSelfie;
  final String? breakTime;
  final String? breakStatus;
  final String? breakSelfie;
  final String? outTime;
  final String? outStatus;
  final String? outSelfie;
  final String? note;

  History({
    required this.id,
    required this.name,
    required this.date,
    this.inTime,
    this.inStatus,
    this.inSelfie,
    this.breakTime,
    this.breakStatus,
    this.breakSelfie,
    this.outTime,
    this.outStatus,
    this.outSelfie,
    this.note,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'] as int,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      inTime: json['in_time'] as String?,
      inStatus: json['in_status'] as String?,
      inSelfie: json['in_selfie'] as String?,
      breakTime: json['break_time'] as String?,
      breakStatus: json['break_status'] as String?,
      breakSelfie: json['break_selfie'] as String?,
      outTime: json['out_time'] as String?,
      outStatus: json['out_status'] as String?,
      outSelfie: json['out_selfie'] as String?,
      note: json['note'] as String?,
    );
  }

  /// Durasi kerja dari inTime ke outTime (format “HH:mm”)
  String get workDuration {
    if (inTime == null || outTime == null) return '-';
    final inDt = DateTime.parse('1970-01-01T$inTime');
    final outDt = DateTime.parse('1970-01-01T$outTime');
    final diff = outDt.difference(inDt);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
