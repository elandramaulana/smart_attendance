import 'package:meta/meta.dart';

/// Jenis submission yang didukung
enum SubmissionType { leave, izin }

extension SubmissionTypeExtension on SubmissionType {
  String get value {
    switch (this) {
      case SubmissionType.leave:
        return 'leave';
      case SubmissionType.izin:
        return 'izin';
    }
  }
}

/// Model untuk form submission (leave, izin, sakit)
@immutable
class SubmissionRequest {
  final SubmissionType submissionType;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String reason;
  final String? jenisIzin;
  final String? lampiran;
  final String? jenisLeave;

  /// Konstruktor untuk leave
  SubmissionRequest.leave({
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.reason,
    required this.jenisLeave,
  })  : submissionType = SubmissionType.leave,
        jenisIzin = null,
        lampiran = null;

  /// Konstruktor untuk izin (bukan sakit)
  SubmissionRequest.izin({
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.reason,
    required this.lampiran,
  })  : submissionType = SubmissionType.izin,
        jenisIzin = 'Izin Resmi',
        jenisLeave = null;

  SubmissionRequest.sakit({
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.reason,
    this.lampiran,
    required bool withDoctorNote,
  })  : submissionType = SubmissionType.izin,
        jenisLeave = null,
        jenisIzin = withDoctorNote ? 'Sakit Surat Dokter' : 'Sakit tanpa Surat';

  /// Ubah menjadi map untuk dikirim sebagai form-data
  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {
      'submission_type': submissionType.value,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'reason': reason,
    };

    if (submissionType == SubmissionType.leave) {
      // Field khusus leave
      data['jenis_leave'] = jenisLeave!;
    } else {
      // Field khusus izin/sakit
      data['jenis_izin'] = jenisIzin!;

      // Hanya sertakan 'lampiran' jika ada isinya
      if (lampiran != null && lampiran!.isNotEmpty) {
        data['lampiran'] = lampiran!;
      }
    }

    return data;
  }
}
