// lib/feature/auth/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/session_manager.dart';
import '../../tasks/Services/task_reprositry.dart';
import '../models/auth_result.dart';
import '../services/hybrid_auth_service.dart';
import '../services/local_auth_service.dart';

enum AuthState { idle, loading, success, failure }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.idle;
  String? _error;
  Map<String, dynamic>? _user;

  // ── Getters ───────────────────────────────────────────────────────────────

  AuthState get state => _state;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _state == AuthState.loading;
  bool get isLoggedIn => _user != null;

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _set(AuthState.loading);

    final result = await HybridAuthService.instance.login(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      _user = await LocalAuthService.instance.getUserByEmail(email);

      // Session + task repository wiring (same as your current login_screen.dart)
      SessionManager.instance.setUser(email);
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        TaskRepository.instance.setUser(firebaseUser.uid);
        await TaskRepository.instance.syncFromFirebase();
      }

      _set(AuthState.success);
    } else {
      _error = result.message;
      _set(AuthState.failure);
    }

    return result;
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<AuthResult> signUp({
    required String name,
    required String? gender,
    required String email,
    required String studentId,
    required int? level,
    required String password,
  }) async {
    _set(AuthState.loading);

    final result = await HybridAuthService.instance.signUp(
      name: name,
      gender: gender,
      email: email,
      studentId: studentId,
      level: level,
      password: password,
    );

    if (result.isSuccess) {
      _user = await LocalAuthService.instance.getUserByEmail(email);
      _set(AuthState.success);
    } else {
      _error = result.message;
      _set(AuthState.failure);
    }

    return result;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await HybridAuthService.instance.signOut();
    SessionManager.instance.clearUser();
    TaskRepository.instance.setUser(null);
    _user = null;
    _error = null;
    _set(AuthState.idle);
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  void _set(AuthState s) {
    _state = s;
    notifyListeners();
  }
}
