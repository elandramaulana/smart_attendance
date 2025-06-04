// lib/model/attendance_today_model.dart
class AttendanceTodayModel {
  final int id;
  final String name;
  final String? inTime;
  final String? inStatus;
  final String? breakTime;
  final String? breakStatus;
  final String? outTime;
  final String? outStatus;
  final String? dailyScore;
  final String? monthlyScore;

  AttendanceTodayModel({
    required this.id,
    required this.name,
    this.inTime,
    this.inStatus,
    this.breakTime,
    this.breakStatus,
    this.outTime,
    this.outStatus,
    this.dailyScore,
    this.monthlyScore,
  });

  factory AttendanceTodayModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AttendanceTodayModel(
      id: data['id'] as int,
      name: data['name'] as String,
      inTime: data['in_time'] as String?,
      inStatus: data['in_status'] as String?,
      breakTime: data['break_time'] as String?,
      breakStatus: data['break_status'] as String?,
      outTime: data['out_time'] as String?,
      outStatus: data['out_status'] as String?,
      dailyScore: data['daily_score']?.toString(),
      monthlyScore: data['monthly_score']?.toString(),
    );
  }

  bool get hasCheckedIn => inTime != null;
  bool get hasOnBreak => breakTime != null;
  bool get hasCheckedOut => outTime != null;
}
