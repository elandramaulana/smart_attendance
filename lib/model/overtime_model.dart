class Overtime {
  final String dateStart;
  final String timeStart;
  final String dateEnd;
  final String timeEnd;
  final String descriptions;

  Overtime({
    required this.dateStart,
    required this.timeStart,
    required this.dateEnd,
    required this.timeEnd,
    required this.descriptions,
  });

  Map<String, String> toJson() {
    return {
      'date_start': dateStart,
      'time_start': timeStart,
      'date_end': dateEnd,
      'time_end': timeEnd,
      'descriptions': descriptions,
    };
  }
}
