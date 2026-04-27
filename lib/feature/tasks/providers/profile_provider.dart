// lib/feature/tasks/providers/profile_provider.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mobile_assignment/core/session_manager.dart';
import 'package:mobile_assignment/feature/auth/providers/auth_provider.dart';
import 'package:mobile_assignment/feature/tasks/Services/profile_service.dart';

enum ProfileState { idle, loading, saving, success, failure }

class ProfileProvider extends ChangeNotifier {
  final _service = ProfileService.instance;
  final _session  = SessionManager.instance;

  ProfileState           _state = ProfileState.idle;
  Map<String, dynamic>?  _user;
  String?                _error;
  String?                _emailOverride;


  ProfileState          get state      => _state;
  Map<String, dynamic>? get user       => _user;
  String?               get error      => _error;
  bool                  get isLoading  => _state == ProfileState.loading;
  bool                  get isSaving   => _state == ProfileState.saving;

  String? get name       => _user?['name'];
  String? get email      => _user?['email'];
  String? get studentId  => _user?['student_id'];
  String? get avatarPath => _user?['avatar_path'];


  void setEmailOverride(String email) {
    _emailOverride = email;
  }

  Future<void> loadUser() async {
    final email = _session.currentUserEmail ?? _emailOverride;
    if (email == null) {
      debugPrint(' ProfileProvider.loadUser: no session email');
      return;
    }

    await loadUserByEmail(email);
  }

  Future<void> loadUserByEmail(String email) async {
    _set(ProfileState.loading);
    final user = await _service.getUserByEmail(email);
    _user = user;
    _set(ProfileState.success);
  }

  Future<bool> updateUser({
    required String name,
    required String studentId,
    required String password,
    File? avatarFile,
  }) async {
    final email = _session.currentUserEmail ?? _emailOverride;
    if (email == null) {
      return false;
    }

    _set(ProfileState.saving);
    final success = await _service.updateUser(
      email:      email,
      name:       name,
      studentId:  studentId,
      password:   password,
      avatarFile: avatarFile,
    );

    if (success) {
      final updated = await _service.getUserByEmail(email);
      _user = updated;
      _set(ProfileState.success);
    } else {
      _error = 'Failed to update profile.';
      _set(ProfileState.failure);
    }

    return success;
  }

  Future<void> logout(AuthProvider authProvider) async {
    await authProvider.logout();
    _user          = null;
    _error         = null;
    _emailOverride = null;
    _set(ProfileState.idle);
  }

  void _set(ProfileState s) {
    _state = s;
    notifyListeners();
  }
}