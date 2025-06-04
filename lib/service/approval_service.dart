import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/approval_model.dart';

class ApprovalService {
  final ApiProvider _api = ApiProvider();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      _api.setBearerToken(token);
    }
  }

  Future<List<Approval>> getApproval() async {
    await _attachToken();
    final resp = await _api.get(Endpoints.approval);
    if (resp['status'] != 'success') {
      throw Exception('Failed to fetch approvals');
    }
    final List data = resp['data'] as List;
    return data
        .map((e) => Approval.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Kirim approve atau reject
  Future<void> actionApproval({
    required int approvalId,
    required String approvalType,
    required String approvalAction, // "approve" atau "reject"
  }) async {
    await _attachToken();
    // Siapkan fields sebagai Map<String, String>
    final fields = {
      'approval_id': approvalId.toString(),
      'approval_type': approvalType,
      'approval_action': approvalAction,
    };

    // Panggil postFormData, bukan post
    final resp = await _api.postFormData(
      Endpoints.approvalAction,
      fields: fields,
    );

    if (resp['success'] != true) {
      throw Exception(resp['message'] ?? 'Failed to $approvalAction approval');
    }
  }
}
