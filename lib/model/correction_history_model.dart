class CorrectionListModel {
  final int id;
  final int userId;
  final int employeeId;
  final String employeeName;
  final DateTime correctionDate;
  final String correctionType;
  final String actualTime;
  final String correctionStatus;

  CorrectionListModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    required this.correctionDate,
    required this.correctionType,
    required this.actualTime,
    required this.correctionStatus,
  });

  factory CorrectionListModel.fromJson(Map<String, dynamic> json) {
    return CorrectionListModel(
      id: json['id'],
      userId: json['user_id'],
      employeeId: json['employee_id'],
      employeeName: json['employee_name'],
      correctionDate: DateTime.parse(json['corection_date']),
      correctionType: json['correction_type'],
      actualTime: json['actual_time'],
      correctionStatus: json['correction_status'],
    );
  }
}
