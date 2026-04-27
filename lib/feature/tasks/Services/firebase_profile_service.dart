import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/imagekit/imagekit_service.dart';

class FirebaseProfileService {
  FirebaseProfileService._();
  static final FirebaseProfileService instance = FirebaseProfileService._();

  static const String _collection = 'user-student';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> saveAvatarImage(File imageFile, String email) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final url = await ImageKitService.instance.uploadImage(
        imageFile: imageFile,
        fileName: '$uid.jpg',
        folder: 'avatars',
      );

      return url;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUser({
    required String email,
    required String name,
    required String studentId,
    required String password,
    File? avatarFile,
  }) async {
    try {
      final user = _auth.currentUser;
      final uid = user?.uid;
      if (uid == null) return false;

      String? avatarUrl;
      if (avatarFile != null) {
        avatarUrl = await saveAvatarImage(avatarFile, email);
      }

      final data = <String, dynamic>{
        'full_name': name,
        'student_id': studentId,
        'university_email': email,
      };
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      await _db
          .collection(_collection)
          .doc(uid)
          .set(data, SetOptions(merge: true));

      if (password.isNotEmpty) {
        try {
          await user!.updatePassword(password);
        } on FirebaseAuthException catch (e) {
          // Password update failed, but profile still saved
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final snap = await _db
          .collection(_collection)
          .where('university_email', isEqualTo: email)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;

      final doc = snap.docs.first;
      return {...doc.data(), 'id': doc.id};
    } catch (e) {
      return null;
    }
  }
}