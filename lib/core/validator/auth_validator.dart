/// Form-field validators for auth (signup / shared rules).
class AuthValidator {
  AuthValidator._();

  /// Generic non-empty check for a labeled field (e.g. login email/password).
  static String? required(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required.';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }
    return null;
  }

  static String? universityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'University email is required.';
    }

    final RegExp pattern = RegExp(r'^(\d+)@stud\.fci-cu\.edu\.eg$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Use format: studentID@stud.fci-cu.edu.eg';
    }
    return null;
  }

  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required.';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Student ID must contain digits only.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must include at least one number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
