import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService();
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  /// Call once at app startup to restore a saved session.
  Future<void> init() async {
    await _api.init();
    if (!_api.hasToken) return;
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        _currentUser = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        await _api.clearToken();
      }
    }
  }

  Future<AuthUser?> login(String email, String password) async {
    try {
      final response = await _api.post('/api/auth/login', {
        'email': email,
        'password': password,
      });
      await _api.setToken(response['access_token'] as String);
      _currentUser = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser?> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final response = await _api.post('/api/auth/signup', {
        'email': email,
        'password': password,
        'name': name,
        'role': role.value,
      });
      await _api.setToken(response['access_token'] as String);
      _currentUser = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<bool> resetPassword(String email) async {
    // Not yet implemented in backend
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty;
  }

  Future<void> updateProfile(AuthUser updatedUser) async {
    _currentUser = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(updatedUser.toJson()));
  }

  Future<void> logout() async {
    _currentUser = null;
    await _api.clearToken();
  }
}
