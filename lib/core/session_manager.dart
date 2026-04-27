// lib/core/session_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  static const _key = 'current_user_email';
  String? _currentUserEmail;

  String? get currentUserEmail => _currentUserEmail;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString(_key);
  }

  Future<void> setUser(String email) async {
    _currentUserEmail = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, email);
  }

  Future<void> clearUser() async {
    _currentUserEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}