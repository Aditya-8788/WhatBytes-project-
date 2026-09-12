import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

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
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      priority:
          TaskPriority.values.asNameMap()[data['priority']] ??
          TaskPriority.medium,
      isCompleted: data['isCompleted'] as bool? ?? false,
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
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      'priority': priority.name,
      'isCompleted': isCompleted,
    };
  }
}