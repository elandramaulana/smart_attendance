class CutiModel {
  final int id;
  final int employeeId;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String tipe;
  final int durationTaken;
  final String jenis;
  final String alasan;
  final String? lampiran;
  final String status;
  final int? leaveBalanceBefore;
  final int? approvedBy;
  final int? leaveBalanceAfter;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CutiModel({
    required this.id,
    required this.employeeId,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.tipe,
    required this.durationTaken,
    required this.jenis,
    required this.alasan,
    this.lampiran,
    required this.status,
    this.leaveBalanceBefore,
    this.approvedBy,
    this.leaveBalanceAfter,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CutiModel.fromJson(Map<String, dynamic> json) {
    return CutiModel(
      id: _parseInt(json['id']),
      employeeId: _parseInt(json['employee_id']),
      tanggalMulai: DateTime.parse(json['tanggal_mulai'] as String),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai'] as String),
      tipe: json['tipe'] as String? ?? '',
      durationTaken: _parseInt(json['duration_taken']),
      jenis: json['jenis'] as String? ?? '',
      alasan: json['alasan'] as String? ?? '',
      lampiran: json['lampiran'] as String?,
      status: json['status'] as String? ?? '',
      leaveBalanceBefore: _parseIntOrNull(json['leave_balance_before']),
      approvedBy: _parseIntOrNull(json['approved_by']),
      leaveBalanceAfter: _parseIntOrNull(json['leave_balance_after']),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Helper untuk parsing int yang bisa jadi String
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper untuk parsing int nullable
  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
      'tipe': tipe,
      'duration_taken': durationTaken,
      'jenis': jenis,
      'alasan': alasan,
      'lampiran': lampiran,
      'status': status,
      'leave_balance_before': leaveBalanceBefore,
      'approved_by': approvedBy,
      'leave_balance_after': leaveBalanceAfter,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
