// lib/feature/tasks/providers/profile_provider.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mobile_assignment/core/session_manager.dart';
import 'package:mobile_assignment/feature/auth/providers/auth_provider.dart';
import 'package:mobile_assignment/feature/tasks/Services/profile_service.dart';

enum ProfileState { idle, loading, saving, success, failure }

class ProfileProvider extends ChangeNotifier {
  final _service = ProfileService.instance;
  final _session = SessionManager.instance;

  ProfileState           _state = ProfileState.idle;
  Map<String, dynamic>?  _user;
  String?                _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  ProfileState          get state      => _state;
  Map<String, dynamic>? get user       => _user;
  String?               get error      => _error;
  bool                  get isLoading  => _state == ProfileState.loading;
  bool                  get isSaving   => _state == ProfileState.saving;

  String? get name       => _user?['name'];
  String? get email      => _user?['email'];
  String? get studentId  => _user?['student_id'];
  String? get avatarPath => _user?['avatar_path'];

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadUser() async {
    final email = _session.currentUserEmail;
    if (email == null) return;

    _set(ProfileState.loading);
    final user = await _service.getUserByEmail(email);
    _user = user;
    _set(ProfileState.success);
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<bool> updateUser({
    required String name,
    required String studentId,
    required String password,
    File? avatarFile,
  }) async {
    final email = _session.currentUserEmail;
    if (email == null) return false;

    _set(ProfileState.saving);

    final success = await _service.updateUser(
      email:      email,
      name:       name,
      studentId:  studentId,
      password:   password,
      avatarFile: avatarFile,
    );

    if (success) {
      await loadUser(); // refresh _user so ProfileScreen updates automatically
    } else {
      _set(ProfileState.failure);
    }

    return success;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout(AuthProvider authProvider) async {
    await authProvider.logout();
    _user  = null;
    _error = null;
    _set(ProfileState.idle);
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  void _set(ProfileState s) {
    _state = s;
    notifyListeners();
  }
}