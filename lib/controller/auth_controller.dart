import 'package:flutter/material.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/service/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _error;

  AuthController(ApiProvider api) : _authService = AuthService(api) {
    _init();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _init() async {
    // On app start, load token and set provider
    final token = await _authService.getToken();
    if (token != null) {
      _authService.api.setBearerToken(token);
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.login(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
