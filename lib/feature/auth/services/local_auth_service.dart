// lib/feature/auth/services/local_auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/auth_result.dart';

class LocalAuthService {
  LocalAuthService._();

  static final LocalAuthService instance = LocalAuthService._();

  static const _databaseName = 'app_auth.db';
  static const _usersTable = 'users';

  Database? _database;

  Future<void> init() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, _databaseName);

    _database = await openDatabase(
      fullPath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_usersTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            gender TEXT,
            email TEXT UNIQUE NOT NULL,
            student_id TEXT UNIQUE NOT NULL,
            level INTEGER,
            password TEXT NOT NULL,
            avatar_path TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE ${_usersTable}_new(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              gender TEXT,
              email TEXT UNIQUE NOT NULL,
              student_id TEXT UNIQUE NOT NULL,
              level INTEGER,
              password TEXT NOT NULL
            )
          ''');
          await db.execute('''
            INSERT INTO ${_usersTable}_new (id, name, gender, email, student_id, level, password)
            SELECT
              id,
              'Unknown',
              NULL,
              email,
              SUBSTR(email, 1, INSTR(email, '@') - 1),
              NULL,
              password
            FROM $_usersTable
          ''');
          await db.execute('DROP TABLE $_usersTable');
          await db.execute('ALTER TABLE ${_usersTable}_new RENAME TO $_usersTable');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE $_usersTable ADD COLUMN avatar_path TEXT',
          );
        }
      },
    );
  }

  Future<AuthResult> signUp({
    required String name,
    required String? gender,
    required String email,
    required String studentId,
    required int? level,
    required String password,
  }) async {
    final db = _database;
    if (db == null) {
      return const AuthResult(
        status: AuthStatus.failure,
        message: 'Database is not ready.',
      );
    }

    try {
      await db.insert(_usersTable, {
        'name': name,
        'gender': gender,
        'email': email,
        'student_id': studentId,
        'level': level,
        'password': password,
      });
      return const AuthResult(
        status: AuthStatus.success,
        message: 'Signup success',
      );
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        return const AuthResult(
          status: AuthStatus.failure,
          message: 'Signup failure: email or student ID already registered.',
        );
      }
      return const AuthResult(
        status: AuthStatus.failure,
        message: 'Signup failure',
      );
    } catch (e) {
      return const AuthResult(
        status: AuthStatus.failure,
        message: 'Signup failure',
      );
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final db = _database;
    if (db == null) {
      return const AuthResult(
        status: AuthStatus.failure,
        message: 'Database is not ready.',
      );
    }

    final users = await db.query(
      _usersTable,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (users.isEmpty) {
      final emailOnly = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );
      if (emailOnly.isEmpty) {
        return const AuthResult(
          status: AuthStatus.failure,
          message: 'Login failure: no account found. Please sign up first.',
        );
      } else {
        return const AuthResult(
          status: AuthStatus.failure,
          message: 'Login failure: incorrect password.',
        );
      }
    }
    return const AuthResult(
      status: AuthStatus.success,
      message: 'Login success',
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = _database;
    if (db == null) return null;

    final users = await db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return users.isEmpty ? null : users.first;
  }

  Database? get database => _database;
}