// lib/model/absence_model.dart

class SickPermitModel {
  final int id;
  final int userId;
  final int employeeId;
  final String employeeName;
  final DateTime submissionDate;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // "Izin" atau "Sakit"
  final String reason;
  final String status;

  SickPermitModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    required this.submissionDate,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    required this.status,
  });

  factory SickPermitModel.fromJson(Map<String, dynamic> json) {
    return SickPermitModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      employeeId: json['employee_id'] as int,
      employeeName: json['employee_name'] as String,
      submissionDate: DateTime.parse(json['submision_date'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      type: json['type'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
    );
  }
}
