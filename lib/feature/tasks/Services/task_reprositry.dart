// lib/feature/tasks/services/task_repository.dart

import 'package:mobile_assignment/feature/tasks/Services/firebase_task_service.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';

import 'local_task_service.dart';
import 'firebase_task_service.dart';

class TaskRepository {
  TaskRepository._();
  static final TaskRepository instance = TaskRepository._();

  final _local   = LocalTaskService.instance;
  final _firebase = FirebaseTaskService.instance;

  // uid is nullable — if null, falls back to local only (offline / not logged in)
  String? _uid;
  bool get _online => _uid != null;

  void setUser(String? uid) => _uid = uid;


  Future<Task> insertTask(Task task) async {
    if (_online) {
      final firebaseId = await _firebase.insertTask(_uid!, task);
      task = task.copyWith(firebaseId: firebaseId);
    }
    final localId = await _local.insertTask(task);
    return task.copyWith(id: localId);
  }

  Future<List<Task>> getAllTasks({
    bool onlyActive = false,
    String? sortBy,
    bool ascending = true
  }) async {
    if (_online) {
      final tasks = await _firebase.getAllTasks(_uid!, onlyActive: onlyActive);
      await _syncToLocal(tasks);
      return _local.getAllTasks(
          onlyActive: onlyActive,
          sortBy: sortBy,
          ascending: ascending
      );
    }
    return _local.getAllTasks(
        onlyActive: onlyActive,
        sortBy: sortBy,
        ascending: ascending
    );
  }

  Future<void> updateTask(Task task) async {
    await _local.updateTask(task);
    if (_online && task.firebaseId != null) await _firebase.updateTask(_uid!, task);
  }

  Future<void> markCompleted(Task task, bool completed) async {
    if (task.id != null) await _local.markCompleted(task.id!, completed);
    if (_online && task.firebaseId != null) {
      await _firebase.markCompleted(_uid!, task.firebaseId!, completed);
    }
  }

  Future<void> deleteTask(Task task) async {
    if (task.id != null) await _local.deleteTask(task.id!);
    if (_online && task.firebaseId != null) await _firebase.deleteTask(_uid!, task.firebaseId!);
  }

  Stream<List<Task>>? watchAllTasks({bool onlyActive = false}) {
    if (!_online) return null;
    return _firebase.watchAllTasks(_uid!, onlyActive: onlyActive);
  }

  Future<void> _syncToLocal(List<Task> tasks) async {
    for (final task in tasks) {
      final existing = await _local.getTaskByFirebaseId(task.firebaseId!);
      if (existing == null) {
        final localId = await _local.insertTask(task);
      } else {
        await _local.updateTask(task.copyWith(id: existing.id));
      }
    }
  }
  Future<void> syncFromFirebase() async {
    if (!_online) return;
    final tasks = await _firebase.getAllTasks(_uid!);
    await _syncToLocal(tasks);
  }
}