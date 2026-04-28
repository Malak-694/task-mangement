import 'package:mobile_assignment/feature/tasks/Services/firebase_task_service.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'local_task_service.dart';

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
      final existing = await _local.getTaskByFirebaseId(
        task.firebaseId!,
        uid: _uid,
      );
      if (existing != null) return task.copyWith(id: existing.id);
      final newLocalId = await _local.insertTask(task, uid: _uid);
      return task.copyWith(id: newLocalId);
    }
    throw Exception('Task must have either id (local) or firebaseId to be updated');
  }

  Future<Task> insertTask(Task task) async {
    if (_online) {
      try {
        final firebaseId = await _firebase
            .insertTask(_uid!, task)
            .timeout(const Duration(seconds: 2));
        task = task.copyWith(firebaseId: firebaseId);
      } catch (_) {}
    }
    final localId = await _local.insertTask(task, uid: _uid);
    return task.copyWith(id: localId);
  }

  Future<List<Task>> getAllTasks({
    String? sortBy,
    bool ascending = true,
  }) async {
    if (_online) {
      try {
        final firebaseTasks = await _firebase
            .getAllTasks(_uid!)
            .timeout(const Duration(seconds: 2));
        await _syncToLocal(firebaseTasks);
      } catch (_) {}
    }
    return _local.getAllTasks(
      uid: _uid,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  Future<void> updateTask(Task task) async {
    task = await _ensureLocalId(task);
    await _local.updateTask(task, uid: _uid);
    if (_online && task.firebaseId != null) {
      try {
        await _firebase
            .updateTask(_uid!, task)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  Future<void> markCompleted(Task task, bool completed) async {
    task = await _ensureLocalId(task);
    await _local.markCompleted(task.id!, completed);
    if (_online && task.firebaseId != null) {
      try {
        await _firebase
            .markCompleted(_uid!, task.firebaseId!, completed)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  Future<void> markFavorite(Task task, bool favorite) async {
    task = await _ensureLocalId(task);
    await _local.markFavorite(task.id!, favorite);
    if (_online && task.firebaseId != null) {
      try {
        await _firebase
            .markFavorite(_uid!, task.firebaseId!, favorite)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  Future<void> deleteTask(Task task) async {
    task = await _ensureLocalId(task);
    await _local.deleteTask(task.id!);
    if (_online && task.firebaseId != null) {
      try {
        await _firebase
            .deleteTask(_uid!, task.firebaseId!)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  Stream<List<Task>>? watchAllTasks({bool onlyActive = false}) {
    if (!_online) return null;
    return _firebase.watchAllTasks(_uid!);
  }

  Future<void> _syncToLocal(List<Task> tasks) async {
    for (final task in tasks) {
      if (task.firebaseId == null) continue;
      final existing = await _local.getTaskByFirebaseId(
        task.firebaseId!,
        uid: _uid,
      );
      if (existing == null) {
        await _local.insertTask(task, uid: _uid);
      } else {
        await _local.updateTask(
          task.copyWith(id: existing.id),
          uid: _uid,
        );
      }
    }
  }

  Future<void> syncFromFirebase() async {
    if (!_online) return;
    try {
      final tasks = await _firebase.getAllTasks(_uid!);
      await _syncToLocal(tasks);
    } catch (_) {}
  }
}