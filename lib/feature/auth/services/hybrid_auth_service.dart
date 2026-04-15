import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../models/auth_result.dart';
import 'local_auth_service.dart';
import 'user_firestore_service.dart';

/// Firebase Auth for identity, [LocalAuthService] (SQLite) for profile storage.
class HybridAuthService {
  HybridAuthService._();

  static final HybridAuthService instance = HybridAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static String _loginFirebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Login failure: no user found for that email.';
      case 'wrong-password':
        return 'Login failure: wrong password.';
      case 'invalid-credential':
        return 'Login failure: invalid email or password.';
      case 'invalid-email':
        return 'Login failure: invalid email address.';
      default:
        return 'Login failure: ${e.message ?? e.code}';
    }
  }

  static String _signupFirebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Signup failure: the password is too weak.';
      case 'email-already-in-use':
        return 'Signup failure: an account already exists for that email.';
      case 'invalid-email':
        return 'Signup failure: invalid email address.';
      default:
        return 'Signup failure: ${e.message ?? e.code}';
    }
  }

  /// Signs in with Firebase, then verifies the same credentials against SQLite.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (!FirebaseBootstrap.isReady) {
      return LocalAuthService.instance.login(
        email: email,
        password: password,
      );
    }

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        status: AuthStatus.failure,
        message: _loginFirebaseMessage(e),
      );
    } catch (e) {
      return AuthResult(
        status: AuthStatus.failure,
        message: 'Login failure: $e',
      );
    }

    final AuthResult local = await LocalAuthService.instance.login(
      email: email,
      password: password,
    );

    if (!local.isSuccess) {
      await _firebaseAuth.signOut();
      return const AuthResult(
        status: AuthStatus.failure,
        message:
            'Login failure: no local profile for this account. Sign up on this device first.',
      );
    }

    return const AuthResult(
      status: AuthStatus.success,
      message: 'Login success',
    );
  }

  /// Creates the Firebase user, then stores the full profile in SQLite.
  /// Rolls back the Firebase account if local insert fails.
  Future<AuthResult> signUp({
    required String name,
    required String? gender,
    required String email,
    required String studentId,
    required int? level,
    required String password,
  }) async {
    if (!FirebaseBootstrap.isReady) {
      return LocalAuthService.instance.signUp(
        name: name,
        gender: gender,
        email: email,
        studentId: studentId,
        level: level,
        password: password,
      );
    }

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        status: AuthStatus.failure,
        message: _signupFirebaseMessage(e),
      );
    } catch (e) {
      return AuthResult(
        status: AuthStatus.failure,
        message: 'Signup failure: $e',
      );
    }

    final AuthResult local = await LocalAuthService.instance.signUp(
      name: name,
      gender: gender,
      email: email,
      studentId: studentId,
      level: level,
      password: password,
    );

    if (!local.isSuccess) {
      try {
        await _firebaseAuth.currentUser?.delete();
      } catch (_) {
        // Best-effort rollback; user should fix via Firebase console if needed.
      }
      await _firebaseAuth.signOut();
      return local;
    }

    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await UserFirestoreService.instance.saveStudentProfileOrLog(
        uid: user.uid,
        fullName: name,
        gender: gender,
        universityEmail: email,
        studentId: studentId,
        academicLevel: level,
      );
    }

    return const AuthResult(
      status: AuthStatus.success,
      message: 'Signup success',
    );
  }

  Future<void> signOut() async {
    if (FirebaseBootstrap.isReady) {
      await _firebaseAuth.signOut();
    }
  }
}
