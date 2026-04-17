// lib/feature/tasks/models/task.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final int? id;
  final String? firebaseId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String priority;
  final DateTime createdAt;
  final bool isCompleted;

  Task({
    this.id,
    this.firebaseId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    DateTime? createdAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'firebase_id': firebaseId,
    'title': title,
    'description': description,
    'due_date': dueDate.toIso8601String(),
    'priority': priority,
    'created_at': createdAt.toIso8601String(),
    'is_completed': isCompleted ? 1 : 0,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    firebaseId: map['firebase_id'],
    title: map['title'],
    description: map['description'],
    dueDate: DateTime.parse(map['due_date']),
    priority: map['priority'],
    createdAt: DateTime.parse(map['created_at']),
    isCompleted: map['is_completed'] == 1,
  );

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'due_date': Timestamp.fromDate(dueDate),
    'priority': priority,
    'created_at': Timestamp.fromDate(createdAt),
    'is_completed': isCompleted,
  };

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Task(
      firebaseId: doc.id,
      title: map['title'],
      description: map['description'],
      dueDate: (map['due_date'] as Timestamp).toDate(),
      priority: map['priority'],
      createdAt: (map['created_at'] as Timestamp).toDate(),
      isCompleted: map['is_completed'] ?? false,
    );
  }

  Task copyWith({
    int? id,
    String? firebaseId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    DateTime? createdAt,
    bool? isCompleted,
  }) =>
      Task(
        id: id ?? this.id,
        firebaseId: firebaseId ?? this.firebaseId,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}