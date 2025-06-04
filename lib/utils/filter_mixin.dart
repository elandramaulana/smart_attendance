import 'package:get/get.dart';
import 'package:intl/intl.dart';

mixin MonthYearFilterMixin on GetxController {
  final List<String> months = DateFormat.MMMM().dateSymbols.MONTHS;
  final List<int> years = List.generate(5, (i) => DateTime.now().year - i);

  final selectedMonth = RxnString();
  final selectedYear = RxnInt();

  String? get monthFilter {
    final m = selectedMonth.value;
    final y = selectedYear.value;
    if (m == null || y == null) return null;
    final idx = months.indexOf(m) + 1;
    final mm = idx.toString().padLeft(2, '0');
    return '$y-$mm';
  }

  void bindFilter(void Function(String? month) fetcher) {
    everAll([selectedMonth, selectedYear], (_) {
      fetcher(monthFilter);
    });
  }
}
