// lib/model/correction_model.dart

class CorrectionRequest {
  final int userId;
  final String correctionType; // 'in','break','out'
  final DateTime date;
  final String correctionTime; // "HH:mm:ss"
  final String reason;

  CorrectionRequest({
    required this.userId,
    required this.correctionType,
    required this.date,
    required this.correctionTime,
    required this.reason,
  });

  Map<String, dynamic> toFormData() {
    return {
      'correction_type': correctionType,
      'date': date.toIso8601String().split('T').first,
      'correction_time': correctionTime,
      'correction_reason': reason,
    };
  }
}

class CorrectionResponse {
  final bool success;
  final String message;

  CorrectionResponse({required this.success, required this.message});

  factory CorrectionResponse.fromJson(Map<String, dynamic> json) {
    return CorrectionResponse(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
    );
  }
}
