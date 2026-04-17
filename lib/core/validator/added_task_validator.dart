class TaskValidator {
  TaskValidator._();

  static String? title(String? v) {
    if (v == null || v.trim().isEmpty) return 'Task title is required.';
    return null;
  }

  static String? dueDate(String? v) {
    if (v == null || v.trim().isEmpty) return 'Due date is required.';
    return null;
  }

  static String? priority(String? v) {
    if (v == null || v.trim().isEmpty) return 'Priority level is required.';
    return null;
  }
}
