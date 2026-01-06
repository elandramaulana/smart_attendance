class AttendanceTodayModel {
  final int id;
  final String name;
  final String? inTime;
  final String? inStatus;
  final String? outTime;
  final String? outStatus;
  final String? dailyScore;
  final String? monthlyScore;

  AttendanceTodayModel({
    required this.id,
    required this.name,
    this.inTime,
    this.inStatus,
    this.outTime,
    this.outStatus,
    this.dailyScore,
    this.monthlyScore,
  });

  factory AttendanceTodayModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AttendanceTodayModel(
      id: data['id'] as int,
      name: data['name'] as String,
      inTime: data['in_time'] as String?,
      inStatus: data['in_status'] as String?,
      outTime: data['out_time'] as String?,
      outStatus: data['out_status'] as String?,
      dailyScore: data['daily_score']?.toString(),
      monthlyScore: data['monthly_score']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'id': id,
        'name': name,
        if (inTime != null) 'in_time': inTime,
        if (inStatus != null) 'in_status': inStatus,
        if (outTime != null) 'out_time': outTime,
        if (outStatus != null) 'out_status': outStatus,
        if (dailyScore != null) 'daily_score': dailyScore,
        if (monthlyScore != null) 'monthly_score': monthlyScore,
      },
    };
  }

  bool get hasCheckedIn => inTime != null;
  bool get hasCheckedOut => outTime != null;
}
