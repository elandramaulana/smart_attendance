import 'dart:convert';

import 'package:intl/intl.dart';

/// Base class untuk semua jenis detail approval
abstract class DetailApproval {}

/// Model untuk "overtime" detail approval
class OvertimeDetail extends DetailApproval {
  final DateTime startDate;
  final DateTime startHour;
  final DateTime endDate;
  final DateTime endHour;

  OvertimeDetail({
    required this.startDate,
    required this.startHour,
    required this.endDate,
    required this.endHour,
  });

  factory OvertimeDetail.fromJson(Map<String, dynamic> json) {
    return OvertimeDetail(
      startDate: DateTime.parse(json['start_date']),
      startHour: DateTime.parse(json['start_hour']),
      endDate: DateTime.parse(json['end_date']),
      endHour: DateTime.parse(json['end_hour']),
    );
  }

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'start_hour': startHour.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'end_hour': endHour.toIso8601String(),
      };
}

/// Model untuk "correction" detail approval
class CorrectionDetail extends DetailApproval {
  final String correctionType;
  final DateTime correctionTime;

  CorrectionDetail({
    required this.correctionType,
    required this.correctionTime,
  });

  factory CorrectionDetail.fromJson(
    Map<String, dynamic> json, {
    // optional: terima tanggal utama untuk menggabungkan
    DateTime? baseDate,
  }) {
    // parse hanya jam dan menit
    final timeOnly = DateFormat('HH:mm').parse(json['correction_time']);
    // jika ingin tanggalnya sama dengan baseDate (misal 2025-05-13):
    final date = baseDate ?? DateTime.now();
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      timeOnly.hour,
      timeOnly.minute,
    );
    return CorrectionDetail(
      correctionType: json['correction_type'] as String,
      correctionTime: combined,
    );
  }

  Map<String, dynamic> toJson() => {
        'correction_type': correctionType,
        // simpan kembali ke format HH:mm jika mau:
        'correction_time': DateFormat('HH:mm').format(correctionTime),
      };
}

/// Model untuk "sick_permit" detail approval
class SickPermitDetail extends DetailApproval {
  final DateTime startDate;
  final DateTime endDate;

  SickPermitDetail({
    required this.startDate,
    required this.endDate,
  });

  factory SickPermitDetail.fromJson(Map<String, dynamic> json) {
    return SickPermitDetail(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };
}

/// Model untuk "leave" detail approval
class LeaveDetail extends DetailApproval {
  final DateTime startDate;
  final DateTime endDate;

  LeaveDetail({
    required this.startDate,
    required this.endDate,
  });

  factory LeaveDetail.fromJson(Map<String, dynamic> json) {
    return LeaveDetail(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };
}

/// Main Approval model
class Approval {
  final int id;
  final int userId;
  final String name;
  final int employeeId;
  final DateTime date;
  final String status;
  final String approvalType;
  final DetailApproval detailApproval;
  final String reason;

  Approval({
    required this.id,
    required this.userId,
    required this.name,
    required this.employeeId,
    required this.date,
    required this.status,
    required this.approvalType,
    required this.detailApproval,
    required this.reason,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    final type = json['approval_type'] as String;
    final detailJson = json['detail_approval'] as Map<String, dynamic>;

    DetailApproval detail;
    switch (type) {
      case 'overtime':
        detail = OvertimeDetail.fromJson(detailJson);
        break;
      case 'correction':
        detail = CorrectionDetail.fromJson(detailJson);
        break;
      case 'sick_permit':
        detail = SickPermitDetail.fromJson(detailJson);
        break;
      case 'leave':
        detail = LeaveDetail.fromJson(detailJson);
        break;
      default:
        throw Exception('Unknown approval type: $type');
    }

    return Approval(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      employeeId: json['employee_id'] as int,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      approvalType: type,
      detailApproval: detail,
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'employee_id': employeeId,
      'date': date.toIso8601String(),
      'status': status,
      'approval_type': approvalType,
      'detail_approval': _detailToJson(),
      'reason': reason,
    };
  }

  /// Helper untuk serialisasi `detailApproval`
  Map<String, dynamic> _detailToJson() {
    if (detailApproval is OvertimeDetail) {
      return (detailApproval as OvertimeDetail).toJson();
    } else if (detailApproval is CorrectionDetail) {
      return (detailApproval as CorrectionDetail).toJson();
    } else if (detailApproval is SickPermitDetail) {
      return (detailApproval as SickPermitDetail).toJson();
    } else if (detailApproval is LeaveDetail) {
      return (detailApproval as LeaveDetail).toJson();
    } else {
      throw Exception('Unsupported DetailApproval type');
    }
  }

  Approval copyWith({
    int? id,
    int? userId,
    String? name,
    int? employeeId,
    DateTime? date,
    String? status,
    String? approvalType,
    DetailApproval? detailApproval,
    String? reason,
  }) {
    return Approval(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      status: status ?? this.status,
      approvalType: approvalType ?? this.approvalType,
      detailApproval: detailApproval ?? this.detailApproval,
      reason: reason ?? this.reason,
    );
  }
}
