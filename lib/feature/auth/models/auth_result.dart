enum AuthStatus {
  success,
  failure,
}

class AuthResult {
  const AuthResult({
    required this.status,
    required this.message,
  });

  final AuthStatus status;
  final String message;

  bool get isSuccess => status == AuthStatus.success;
}
