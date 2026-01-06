class TextFormatterHelper {
  // Format leave type
  static String formatLeaveType(String leaveType) {
    final Map<String, String> leaveTypeMap = {
      'cuti_tahunan': 'Cuti Tahunan',
      'cuti_melahirkan': 'Cuti Melahirkan',
      'cuti_anak_khitan': 'Cuti Anak Khitan',
      'cuti_nikah': 'Cuti Nikah',
      'cuti_pernikahan_anak': 'Cuti Pernikahan Anak',
      'cuti_kematian': 'Cuti Kematian',
      'cuti_izin_pribadi': 'Cuti Izin Pribadi',
    };

    return leaveTypeMap[leaveType] ?? leaveType;
  }

  // Format sick type
  static String formatSickType(String sickType) {
    final Map<String, String> sickTypeMap = {
      'dengan_surat': 'Dengan Surat Dokter',
      'tanpa_surat': 'Tanpa Surat Dokter',
    };

    return sickTypeMap[sickType] ?? sickType;
  }

  // Generic formatter untuk underscore ke title case
  static String formatUnderscoreToTitleCase(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}
