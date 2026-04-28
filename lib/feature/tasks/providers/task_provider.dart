// lib/feature/tasks/providers/task_provider.dart

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
      _set(TaskState.loading);
      _subscription = stream.listen(
            (tasks) {
          _tasks = tasks;
          _set(TaskState.success);
        },
        onError: (e) {
          _error = e.toString();
          _set(TaskState.failure);
        },
      );
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
    await _repo.insertTask(task);
    if (_subscription == null) await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _repo.updateTask(task);
    if (_subscription == null) {
      final i = _tasks.indexWhere((t) => t.id == task.id);
      if (i != -1) _tasks[i] = task;
      notifyListeners();
    }
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _repo.markCompleted(task, updated.isCompleted);
    if (_subscription == null) {
      final i = _tasks.indexWhere((t) => t.id == task.id);
      if (i != -1) _tasks[i] = updated;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Task task) async {
    final updated = task.copyWith(isFavorite: !task.isFavorite);
    await _repo.markFavorite(task, updated.isFavorite);
    if (_subscription == null) {
      final i = _tasks.indexWhere((t) => t.id == task.id);
      if (i != -1) _tasks[i] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    await _repo.deleteTask(task);
    if (_subscription == null) {
      _tasks.removeWhere((t) => t.id == task.id);
      notifyListeners();
    }
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