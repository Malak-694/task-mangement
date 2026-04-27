import 'dart:async';
import 'dart:io';

import 'package:mobile_assignment/core/firebase/firebase_bootstrap.dart';

import 'firebase_profile_service.dart';
import 'local_profile_service.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  Future<String?> saveAvatarImage(File imageFile, String email) {
    if (FirebaseBootstrap.isReady) {
      return FirebaseProfileService.instance.saveAvatarImage(imageFile, email);
    }
    return LocalProfileService.instance.saveAvatarImage(imageFile, email);
  }

  Future<bool> updateUser({
    required String email,
    required String name,
    required String studentId,
    required String password,
    File? avatarFile,
  }) async {
    final localSuccess = await LocalProfileService.instance.updateUser(
      email: email,
      name: name,
      password: password,
      studentId: studentId,
      avatarFile: avatarFile,
    );

    if (!localSuccess) {
      return false;
    }

    if (FirebaseBootstrap.isReady) {
      unawaited(
        FirebaseProfileService.instance
            .updateUser(
          email: email,
          name: name,
          password: password,
          studentId: studentId,
          avatarFile: avatarFile,
        )
            .catchError((e) => null),
      );
    }

    return true;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final localUser = await LocalProfileService.instance.getUserByEmail(email);

    if (!FirebaseBootstrap.isReady) {
      return localUser;
    }

    Map<String, dynamic>? firebaseUser;
    try {
      firebaseUser = await FirebaseProfileService.instance.getUserByEmail(email);
    } catch (e) {
      firebaseUser = null;
    }

    if (firebaseUser == null) {
      return localUser;
    }

    final localAvatarPath = localUser?['avatar_path'];
    final firebaseAvatarUrl = firebaseUser['avatar_url'] ?? firebaseUser['avatar_path'];

    return {
      'name': firebaseUser['full_name'] ?? firebaseUser['name'] ?? localUser?['name'] ?? '',
      'email': firebaseUser['university_email'] ?? firebaseUser['email'] ?? localUser?['email'] ?? '',
      'student_id': firebaseUser['student_id'] ?? localUser?['student_id'] ?? '',
      'gender': firebaseUser['gender'] ?? localUser?['gender'],
      'id': firebaseUser['id'] ?? localUser?['id'],
      'password': localUser?['password'] ?? '',
      'avatar_path': localAvatarPath ?? firebaseAvatarUrl,
    };
  }
}