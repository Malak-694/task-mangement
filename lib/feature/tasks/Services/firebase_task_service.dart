import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';

class FirebaseTaskService {
  FirebaseTaskService._();
  static final FirebaseTaskService instance = FirebaseTaskService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('user-student').doc(uid).collection('tasks');

  Future<String> insertTask(String uid, Task task) async {
    final ref = await _col(uid).add(task.toFirestore());
    return ref.id;
  }

  Future<void> updateTask(String uid, Task task) async {
    if (task.firebaseId == null) {
      throw Exception('Cannot update task without firebaseId');
    }
    await _col(uid).doc(task.firebaseId).update(task.toFirestore());
  }

  Future<void> markCompleted(
    String uid,
    String firebaseId,
    bool completed,
  ) async {
    await _col(uid).doc(firebaseId).update({'is_completed': completed});
  }

  Future<void> markFavorite(
    String uid,
    String firebaseId,
    bool favorite,
  ) async {
    await _col(uid).doc(firebaseId).update({'is_favorite': favorite});
  }

  Future<void> deleteTask(String uid, String firebaseId) async {
    await _col(uid).doc(firebaseId).delete();
  }

  Future<Task?> getTaskById(String uid, String firebaseId) async {
    final doc = await _col(uid).doc(firebaseId).get();
    if (!doc.exists) return null;
    return Task.fromFirestore(doc);
  }

  Future<List<Task>> getAllTasks(String uid, {bool onlyActive = false}) async {
    Query<Map<String, dynamic>> q = _col(uid).orderBy('due_date');
    if (onlyActive) q = q.where('is_completed', isEqualTo: false);
    final snap = await q.get();
    return snap.docs.map(Task.fromFirestore).toList();
  }

  Stream<List<Task>> watchAllTasks(String uid, {bool onlyActive = false}) {
    Query<Map<String, dynamic>> q = _col(uid).orderBy('due_date');
    if (onlyActive) q = q.where('is_completed', isEqualTo: false);
    return q.snapshots().map((s) => s.docs.map(Task.fromFirestore).toList());
  }
}
