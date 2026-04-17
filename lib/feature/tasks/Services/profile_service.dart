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
    File? avatarFile,
  }) async {
    // Always write to local so the app works offline
    await LocalProfileService.instance.updateUser(
      email: email,
      name: name,
      studentId: studentId,
      avatarFile: FirebaseBootstrap.isReady ? null : avatarFile,
    );

    if (FirebaseBootstrap.isReady) {
      return FirebaseProfileService.instance.updateUser(
        email: email,
        name: name,
        studentId: studentId,
        avatarFile: avatarFile,
      );
    }

    return true;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Map<String, dynamic>? user;

    if (FirebaseBootstrap.isReady) {
      // Get from Firebase
      user = await FirebaseProfileService.instance.getUserByEmail(email);

      if (user != null) {
        return {
          'name': user['full_name'] ?? user['name'] ?? '—',
          'email': user['university_email'] ?? user['email'] ?? '—',
          'student_id': user['student_id'] ?? '—',
          'avatar_path': user['avatar_url'] ?? user['avatar_path'],
          'gender': user['gender'],
          'id': user['id'], // Firestore doc ID
        };
      }
    } else {
      // Get from Local (already has correct field names)
      user = await LocalProfileService.instance.getUserByEmail(email);
    }

    return user;
  }
}