

// lib/feature/tasks/data/local_task_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class LocalTaskService {

  LocalTaskService._();
  static final LocalTaskService instance = LocalTaskService._();

  static const _databaseName = 'app_tasks.db';
  static const _tasksTable = 'tasks';

  Database? _database;

  Future<void> init() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, _databaseName);

    _database = await openDatabase(
      fullPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.rawQuery('PRAGMA journal_mode = WAL');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tasksTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebase_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        priority TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_tasks_due_date ON $_tasksTable(due_date)');
    await db.execute('CREATE INDEX idx_tasks_priority ON $_tasksTable(priority)');
    await db.execute('CREATE INDEX idx_tasks_completed ON $_tasksTable(is_completed)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE ${_tasksTable}_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firebase_id TEXT,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT NOT NULL,
          priority TEXT NOT NULL,
          created_at TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          reminder_enabled INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute('''
        INSERT INTO ${_tasksTable}_new (
          id, title, description, due_date, priority, created_at, is_completed
        )
        SELECT id, title, description, due_date, priority, created_at, is_completed
        FROM $_tasksTable
      ''');

      await db.execute('DROP TABLE $_tasksTable');
      await db.execute('ALTER TABLE ${_tasksTable}_new RENAME TO $_tasksTable');
    }
  }


  Future<int> insertTask(Task task) async {
    final db = await _ensureDb();
    return await db.insert(_tasksTable, task.toMap());
  }


  Future<Task?> getTaskById(int id) async {
    final db = await _ensureDb();
    final maps = await db.query(
      _tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<List<Task>> getAllTasks({
    bool onlyActive = false,
    String? sortBy,
    bool ascending = true,
  }) async {
    final db = await _ensureDb();
    final where = onlyActive ? 'is_completed = 0' : null;
    final orderBy = sortBy != null
        ? '$sortBy ${ascending ? 'ASC' : 'DESC'}'
        : 'due_date ASC';

    final maps = await db.query(
      _tasksTable,
      where: where,
      orderBy: orderBy,
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByPriority(String priority) async {
    final db = await _ensureDb();
    final maps = await db.query(
      _tasksTable,
      where: 'priority = ? AND is_completed = 0',
      whereArgs: [priority],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getOverdueTasks() async {
    final db = await _ensureDb();
    final now = DateTime.now().toIso8601String();
    final maps = await db.rawQuery('''
      SELECT * FROM $_tasksTable
      WHERE due_date < ? AND is_completed = 0
      ORDER BY due_date ASC
    ''', [now]);
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }


  Future<int> updateTask(Task task) async {
    final db = await _ensureDb();
    if (task.id == null) throw Exception('Cannot update task without id');
    return await db.update(
      _tasksTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> markCompleted(int id, bool completed) async {
    final db = await _ensureDb();
    return await db.update(
      _tasksTable,
      {'is_completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _ensureDb();
    return await db.delete(
      _tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCompletedTasks() async {
    final db = await _ensureDb();
    return await db.delete(
      _tasksTable,
      where: 'is_completed = ?',
      whereArgs: [1],
    );
  }

  Future<Task?> getTaskByFirebaseId(String firebaseId) async {
    final db = await _ensureDb();
    final maps = await db.query(
      _tasksTable,
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<Database> _ensureDb() async {
    if (_database == null) await init();
    return _database!;
  }

  Future<void> close() async {
    final db = await _ensureDb();
    await db.close();
    _database = null;
  }


}