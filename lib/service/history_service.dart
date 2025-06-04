// lib/service/history_service.dart

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/history_model.dart';

class HistoryService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      _api.setBearerToken(token);
    }
  }

  /// Ambil history user dengan rentang tanggal
  Future<List<History>> getHistory({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _attachToken();

    final s = DateFormat('yyyy-MM-dd').format(startDate);
    final e = DateFormat('yyyy-MM-dd').format(endDate);
    final path =
        '/attendance/user/history?user_id=$userId&start_date=$s&end_date=$e';

    final resp = await _api.get(path);
    if (resp['success'] != true) {
      throw Exception('Failed to fetch history');
    }

    final List data = resp['data'] as List;
    return data.map((e) => History.fromJson(e)).toList();
  }
}
