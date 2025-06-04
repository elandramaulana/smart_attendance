class CutiModel {
  final int id;
  final int userId;
  final int employeeId;
  final String employeeName;
  final DateTime submissionDate;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String leaveType;
  final String reason;
  final String status;

  CutiModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    required this.submissionDate,
    required this.dateStart,
    required this.dateEnd,
    required this.leaveType,
    required this.reason,
    required this.status,
  });

  factory CutiModel.fromJson(Map<String, dynamic> json) {
    return CutiModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      employeeId: json['employee_id'] as int,
      employeeName: json['employee_name'] as String,
      submissionDate: DateTime.parse(json['submision_date'] as String),
      dateStart: DateTime.parse(json['date_start'] as String),
      dateEnd: DateTime.parse(json['date_end'] as String),
      leaveType: json['leave_type'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
    );
  }
}
