import 'package:meta/meta.dart';

/// Jenis submission yang didukung
enum SubmissionType { leave, sakit }

extension SubmissionTypeExtension on SubmissionType {
  String get value {
    switch (this) {
      case SubmissionType.leave:
        return 'leave';
      case SubmissionType.sakit:
        return 'izin';
    }
  }
}

@immutable
class SubmissionRequest {
  final SubmissionType submissionType;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String keterangan;
  final String? lampiran;
  final String? jenisCuti;

  /// Konstruktor untuk cuti/leave
  const SubmissionRequest.leave({
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required String reason,
    required String jenisLeave,
    this.lampiran,
  })  : submissionType = SubmissionType.leave,
        keterangan = reason,
        jenisCuti = jenisLeave;

  /// Konstruktor untuk izin sakit
  const SubmissionRequest.sakit({
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required String reason,
    required String jenisSakit,
    this.lampiran,
  })  : submissionType = SubmissionType.sakit,
        keterangan = reason,
        jenisCuti = jenisSakit;

  /// Convert ke Map untuk form-data
  /// PENTING: Semua jenis menggunakan field "jenis_cuti" sesuai API
  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'keterangan': keterangan,
      'jenis_cuti': jenisCuti ?? '',
    };

    // PENTING: JANGAN kirim field lampiran jika tidak ada
    // Hanya tambahkan field lampiran jika memang ada isinya
    if (lampiran != null && lampiran!.isNotEmpty) {
      data['lampiran'] = lampiran!;
    }
    // Jika lampiran null/kosong, field ini tidak dikirim sama sekali

    return data;
  }

  /// Alias untuk toFormData
  Map<String, dynamic> toJson() => toFormData();

  @override
  String toString() {
    return 'SubmissionRequest('
        'type: ${submissionType.value}, '
        'dates: $tanggalMulai to $tanggalSelesai, '
        'jenisCuti: $jenisCuti, '
        'hasLampiran: ${lampiran != null && lampiran!.isNotEmpty}'
        ')';
  }
}
