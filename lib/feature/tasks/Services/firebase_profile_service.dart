import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseProfileService {
  FirebaseProfileService._();
  static final FirebaseProfileService instance = FirebaseProfileService._();

  static const String _collection = 'user-student';

  final FirebaseFirestore _db      = FirebaseFirestore.instance;
  final FirebaseStorage   _storage = FirebaseStorage.instance;
  final FirebaseAuth      _auth    = FirebaseAuth.instance;

  Future<String?> saveAvatarImage(File imageFile, String email) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final ref = _storage.ref().child('avatars').child('$uid.jpg');

      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } catch (e, st) {
      debugPrint('FirebaseProfileService.saveAvatarImage failed: $e\n$st');
      return null;
    }
  }

  Future<bool> updateUser({
    required String email,
    required String name,
    required String studentId,
    File? avatarFile,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      String? avatarUrl;
      if (avatarFile != null) {
        avatarUrl = await saveAvatarImage(avatarFile, email);
      }

      final data = <String, dynamic>{
        'full_name':        name,
        'student_id':       studentId,
        'university_email': email,
      };

      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
      }

      await _db
          .collection(_collection)
          .doc(uid)
          .set(data, SetOptions(merge: true));

      return true;
    } catch (e, st) {
      debugPrint('FirebaseProfileService.updateUser failed: $e\n$st');
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
    } catch (e, st) {
      debugPrint('FirebaseProfileService.getUserByEmail failed: $e\n$st');
      return null;
    }
  }
}