import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

abstract final class TaskFields {
  static const String userId = 'userId';
  static const String title = 'title';
  static const String description = 'description';
  static const String dueDate = 'dueDate';
  static const String priority = 'priority';
  static const String isCompleted = 'isCompleted';
}

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    super.dueDate,
    super.priority,
    super.isCompleted,
  });

  factory TaskModel.fromEntity(TaskEntity task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: task.isCompleted,
    );
  }

  factory TaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw const FormatException('Task data is null');
    }
    return TaskModel(
      id: snapshot.id,
      title: data[TaskFields.title] as String,
      description: data[TaskFields.description] as String? ?? '',
      dueDate: (data[TaskFields.dueDate] as Timestamp?)?.toDate(),
      priority:
          TaskPriority.values.asNameMap()[data[TaskFields.priority]] ??
          TaskPriority.medium,
      isCompleted: data[TaskFields.isCompleted] as bool? ?? false,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority:
          TaskPriority.values.asNameMap()[json['priority']] ??
          TaskPriority.medium,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      TaskFields.title: title,
      TaskFields.description: description,
      TaskFields.dueDate: dueDate?.toIso8601String(),
      TaskFields.priority: priority.name,
      TaskFields.isCompleted: isCompleted,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      TaskFields.title: title,
      TaskFields.description: description,
      if (dueDate != null) TaskFields.dueDate: Timestamp.fromDate(dueDate!),
      TaskFields.priority: priority.name,
      TaskFields.isCompleted: isCompleted,
    };
  }
}