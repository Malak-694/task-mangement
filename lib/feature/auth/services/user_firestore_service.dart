import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Persists student profile documents in Firestore.
///
/// Collection: `user-student`, document id: Firebase Auth `uid`.
///
/// **Security:** Do not put real passwords in Firestore. The `password` field
/// is kept empty; authentication uses Firebase Auth (and your local DB for offline).
///
/// **Rules (example):** allow create, update if `request.auth != null &&
/// request.auth.uid == resource.id` for `user-student/{userId}`.
class UserFirestoreService {
  UserFirestoreService._();

  static final UserFirestoreService instance = UserFirestoreService._();

  static const String collectionName = 'user-student';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Writes/merges the student profile for [uid].
  Future<void> saveStudentProfile({
    required String uid,
    required String fullName,
    required String? gender,
    required String universityEmail,
    required String studentId,
    required int? academicLevel,
  }) async {
    await _db.collection(collectionName).doc(uid).set(
      <String, dynamic>{
        'Gender': gender ?? '',
        'academic_level': academicLevel?.toString() ?? '',
        'full_name': fullName,
        // Intentionally empty — never store plaintext passwords in Firestore.
        'student_id': studentId,
        'university_email': universityEmail,
      },
      SetOptions(merge: true),
    );
  }

  /// Call after signup/login when you want cloud to mirror local; logs only on failure.
  Future<void> saveStudentProfileOrLog({
    required String uid,
    required String fullName,
    required String? gender,
    required String universityEmail,
    required String studentId,
    required int? academicLevel,
  }) async {
    try {
      await saveStudentProfile(
        uid: uid,
        fullName: fullName,
        gender: gender,
        universityEmail: universityEmail,
        studentId: studentId,
        academicLevel: academicLevel,
      );
    } catch (e, st) {
      debugPrint('Firestore user-student sync failed: $e\n$st');
    }
  }
}
