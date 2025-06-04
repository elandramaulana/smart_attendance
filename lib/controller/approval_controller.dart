import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance/core/app_routes.dart';
import 'package:smart_attendance/model/approval_model.dart';
import 'package:smart_attendance/service/approval_service.dart';

class ApprovalController extends GetxController {
  final ApprovalService _service = ApprovalService();

  var approvals = <Approval>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final _dateFmt = DateFormat('dd MMM yyyy');
  final _timeFmt = DateFormat('HH:mm');
  final _dateTimeFmt = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void onInit() {
    super.onInit();
    fetchApprovals();
  }

  Future<void> fetchApprovals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _service.getApproval();
      approvals.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve(Approval a) async {
    await _handleAction(a, 'approve', 'disetujui');
  }

  Future<void> reject(Approval a) async {
    await _handleAction(a, 'reject', 'ditolak');
  }

  Future<void> _handleAction(
      Approval a, String action, String newStatus) async {
    try {
      isLoading.value = true;

      await _service.actionApproval(
        approvalId: a.id,
        approvalType: a.approvalType,
        approvalAction: action,
      );

      // update status di list
      final idx = approvals.indexWhere((x) => x.id == a.id);
      if (idx != -1) {
        approvals[idx] = approvals[idx].copyWith(status: newStatus);
      }

      Get.snackbar(
        'Berhasil',
        'Approval berhasil $newStatus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Format tanggal request untuk ditampilkan di UI
  String formattedDateTime(Approval a) {
    return _dateTimeFmt.format(a.date);
  }

  /// Buat description berdasarkan jenis approval
  String description(Approval a) {
    final d = a.detailApproval;
    switch (a.approvalType) {
      case 'sick_permit':
      case 'leave':
        // keduanya punya startDate & endDate
        final start = (d as dynamic).startDate as DateTime;
        final end = (d as dynamic).endDate as DateTime;
        if (_dateFmt.format(start) == _dateFmt.format(end)) {
          return _dateFmt.format(start);
        }
        return '${_dateFmt.format(start)} – ${_dateFmt.format(end)}';

      case 'overtime':
        final od = d as OvertimeDetail;
        return '${_dateFmt.format(od.startDate)} '
            '(${_timeFmt.format(od.startHour)}–${_timeFmt.format(od.endHour)})';

      case 'correction':
        final cd = d as CorrectionDetail;
        return '${cd.correctionType},${_dateFmt.format(cd.correctionTime)} '
            '| ${_timeFmt.format(cd.correctionTime)}';

      default:
        return '-';
    }
  }
}
