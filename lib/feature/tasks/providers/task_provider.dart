import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../Services/task_reprositry.dart';

enum TaskState { idle, loading, success, failure }

class TaskProvider extends ChangeNotifier {
  final _repo = TaskRepository.instance;

  TaskState _state = TaskState.idle;
  List<Task> _tasks = [];
  String? _error;
  StreamSubscription<List<Task>>? _subscription;

  TaskState get state => _state;
  List<Task> get tasks => _tasks;
  List<Task> get favoriteTasks =>
      _tasks.where((task) => task.isFavorite).toList();
  String? get error => _error;
  bool get isLoading => _state == TaskState.loading;
  int get count => _tasks.length;
  int get favoriteCount => favoriteTasks.length;

  Duration remainingFor(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return task.dueDate.difference(current);
  }

  String remainingLabelFor(Task task, {DateTime? now}) {
    final remaining = remainingFor(task, now: now);
    if (remaining.isNegative) {
      final overdue = remaining.abs();
      if (overdue.inDays >= 1) {
        return 'Overdue by ${overdue.inDays} day${overdue.inDays == 1 ? '' : 's'}';
      }
      final hours = overdue.inHours;
      return 'Overdue by $hours hour${hours == 1 ? '' : 's'}';
    }
    if (remaining.inDays >= 1) {
      return '${remaining.inDays} day${remaining.inDays == 1 ? '' : 's'}';
    }
    final hours = remaining.inHours;
    if (hours >= 1) return '$hours hour${hours == 1 ? '' : 's'}';
    final minutes = remaining.inMinutes;
    if (minutes >= 1) return '$minutes minute${minutes == 1 ? '' : 's'}';
    return 'Less than a minute';
  }

  void startWatching() {
    _subscription?.cancel();
    final stream = _repo.watchAllTasks();

    if (stream != null) {
      loadTasks().then((_) {
        _subscription = stream.listen(
              (tasks) {
            _tasks = tasks;
            _set(TaskState.success);
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
      });
    } else {
      loadTasks();
    }
  }

  Future<void> loadTasks({
    bool onlyActive = false,
    String? sortBy,
    bool ascending = true,
  }) async {
    _set(TaskState.loading);
    try {
      _tasks = await _repo.getAllTasks(
        sortBy: sortBy,
        ascending: ascending,
      );
      _set(TaskState.success);
    } catch (e) {
      _error = e.toString();
      _set(TaskState.failure);
    }
  }

  Future<void> addTask(Task task) async {
    final saved = await _repo.insertTask(task);
    debugPrint('Inserted task id: ${saved.id}, firebase: ${saved.firebaseId}');
    debugPrint('Tasks before reload: ${_tasks.length}');
    if (_subscription != null) {
      return;
    }
    await loadTasks();
    debugPrint('Tasks after reload: ${_tasks.length}');
  }

  Future<void> updateTask(Task task) async {
    await _repo.updateTask(task);
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
    notifyListeners();
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _repo.markCompleted(task, updated.isCompleted);
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = updated;
    notifyListeners();
  }

  Future<void> toggleFavorite(Task task) async {
    final updated = task.copyWith(isFavorite: !task.isFavorite);
    await _repo.markFavorite(task, updated.isFavorite);
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = updated;
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    final resolved = await _repo.deleteTask(task);
    if (_subscription != null) return;
    _tasks.removeWhere((t) =>
    t.id == resolved.id ||
        (t.firebaseId != null && t.firebaseId == resolved.firebaseId)
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _set(TaskState s) {
    _state = s;
    notifyListeners();
  }
}