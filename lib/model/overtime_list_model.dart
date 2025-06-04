// lib/model/overtime_model.dart

class OvertimeListModel {
  final int id;
  final int userId;
  final int employeeId;
  final String employeeName;
  final DateTime createdAt;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String timeStart;
  final String timeEnd;
  final String status;

  OvertimeListModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    required this.createdAt,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
  });

  factory OvertimeListModel.fromJson(Map<String, dynamic> json) {
    return OvertimeListModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      employeeId: json['employee_id'] as int,
      employeeName: json['employee_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      dateStart: DateTime.parse(json['date_start'] as String),
      dateEnd: DateTime.parse(json['date_end'] as String),
      timeStart: json['time_start'] as String,
      timeEnd: json['time_end'] as String,
      status: json['status'] as String,
    );
  }
}
