// lib/feature/tasks/services/task_repository.dart

import 'package:mobile_assignment/feature/tasks/Services/firebase_task_service.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'local_task_service.dart';
import 'firebase_task_service.dart';

class TaskRepository {
  TaskRepository._();
  static final TaskRepository instance = TaskRepository._();

  final _local = LocalTaskService.instance;
  final _firebase = FirebaseTaskService.instance;
  String? _uid;
  bool get _online => _uid != null;

  void setUser(String? uid) => _uid = uid;


  Future<Task> _ensureLocalId(Task task) async {
    if (task.id != null) return task;
    if (task.firebaseId != null) {
      final existing = await _local.getTaskByFirebaseId(task.firebaseId!);
      if (existing != null) {
        return task.copyWith(id: existing.id);
      }
      final newLocalId = await _local.insertTask(task);
      return task.copyWith(id: newLocalId);
    }

    throw Exception('Task must have either id (local) or firebaseId to be updated');
  }

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
    bool ascending = true,
  }) async {
    if (_online) {
      final firebaseTasks = await _firebase.getAllTasks(_uid!, onlyActive: onlyActive);
      await _syncToLocal(firebaseTasks);
      return _local.getAllTasks(
        onlyActive: onlyActive,
        sortBy: sortBy,
        ascending: ascending,
      );
    }
    return _local.getAllTasks(
      onlyActive: onlyActive,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  Future<void> updateTask(Task task) async {
    task = await _ensureLocalId(task);

    await _local.updateTask(task);
    if (_online && task.firebaseId != null) {
      await _firebase.updateTask(_uid!, task);
    }
  }

  Future<void> markCompleted(Task task, bool completed) async {
    task = await _ensureLocalId(task);

    await _local.markCompleted(task.id!, completed);

    if (_online && task.firebaseId != null) {
      await _firebase.markCompleted(_uid!, task.firebaseId!, completed);
    }
  }

  Future<void> markFavorite(Task task, bool favorite) async {
    task = await _ensureLocalId(task);

    await _local.markFavorite(task.id!, favorite);

    if (_online && task.firebaseId != null) {
      await _firebase.markFavorite(_uid!, task.firebaseId!, favorite);
    }
  }

  Future<void> deleteTask(Task task) async {
    task = await _ensureLocalId(task);

    await _local.deleteTask(task.id!);

    if (_online && task.firebaseId != null) {
      await _firebase.deleteTask(_uid!, task.firebaseId!);
    }
  }

  Stream<List<Task>>? watchAllTasks({bool onlyActive = false}) {
    if (!_online) return null;
    return _firebase.watchAllTasks(_uid!, onlyActive: onlyActive);
  }


  Future<void> _syncToLocal(List<Task> tasks) async {
    for (final task in tasks) {
      if (task.firebaseId == null) continue;

      final existing = await _local.getTaskByFirebaseId(task.firebaseId!);
      if (existing == null) {
        await _local.insertTask(task);
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

  Future<void> updateTaskResilient(Task task) async {
    task = await _ensureLocalId(task);

    bool localSuccess = false;
    bool firebaseSuccess = false;

    try {
      await _local.updateTask(task);
      localSuccess = true;
    } catch (e) {
      print('Local update failed: $e');

    }

    if (_online && task.firebaseId != null) {
      try {
        await _firebase.updateTask(_uid!, task);
        firebaseSuccess = true;
      } catch (e) {
        print('Firebase update failed: $e');
      }
    }

    if (!localSuccess && !firebaseSuccess) {
      throw Exception('Failed to update task on both local and Firebase');
    }
  }
}