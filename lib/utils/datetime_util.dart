import 'package:intl/intl.dart';

class DateTimeUtil {
  static String getFormattedDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String getFormattedTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}

class IndonesianDateFormatter {
  static const List<String> _hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  /// Mendapatkan nama hari dalam bahasa Indonesia
  static String getNamaHari(DateTime date) {
    return _hari[date.weekday - 1];
  }

  /// Mendapatkan nama bulan dalam bahasa Indonesia
  static String getNamaBulan(DateTime date) {
    return _bulan[date.month - 1];
  }

  /// Format datetime lengkap dalam bahasa Indonesia
  /// Contoh: "Senin, 12 Mei 2023"
  static String formatTanggalLengkap(DateTime date) {
    return '${getNamaHari(date)}, ${date.day} ${getNamaBulan(date)} ${date.year}';
  }

  /// Format tanggal pendek
  /// Contoh: "12 Mei 2023"
  static String formatTanggalPendek(DateTime date) {
    return '${date.day} ${getNamaBulan(date)} ${date.year}';
  }

  /// Format dengan jam
  /// Contoh: "Senin, 12 Mei 2023 14:30"
  static String formatTanggalJam(DateTime date) {
    return '${formatTanggalLengkap(date)} ${_formatJam(date)}';
  }

  /// Format jam dengan leading zero
  static String _formatJam(DateTime date) {
    String jam = date.hour.toString().padLeft(2, '0');
    String menit = date.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  /// Mendapatkan sapa sesuai waktu
  static String getSapa() {
    var sekarang = DateTime.now();
    if (sekarang.hour < 10) {
      return 'Selamat Pagi';
    } else if (sekarang.hour < 15) {
      return 'Selamat Siang';
    } else if (sekarang.hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}
