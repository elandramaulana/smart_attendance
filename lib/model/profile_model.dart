class Profile {
  final String fullName;
  final String profilePicture;
  final String noEmployee;
  final String companyName;
  final String companyType;
  final String address;
  final String divisionName;
  final String positionName;
  final String logo;

  Profile({
    required this.fullName,
    required this.profilePicture,
    required this.noEmployee,
    required this.companyName,
    required this.companyType,
    required this.address,
    required this.divisionName,
    required this.positionName,
    required this.logo,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      fullName: json['full_name'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
      noEmployee: json['no_employee'] as String? ?? '',
      companyName: json['nama_company'] as String? ?? '',
      companyType: json['tipe_company'] as String? ?? '',
      address: json['alamat'] as String? ?? '',
      divisionName: json['division_name'] as String? ?? '',
      positionName: json['position_name'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'profile_picture': profilePicture,
        'no_employee': noEmployee,
        'nama_company': companyName,
        'tipe_company': companyType,
        'alamat': address,
        'division_name': divisionName,
        'position_name': positionName,
        'logo': logo,
      };
}
