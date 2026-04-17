

// lib/core/session/session_manager.dart

class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  String? currentUserEmail;

  void setUser(String email) => currentUserEmail = email;
  void clearUser() => currentUserEmail = null;
}