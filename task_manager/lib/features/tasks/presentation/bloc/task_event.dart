import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';
import 'task_filter.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;

  const LoadTasks({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddTask extends TaskEvent {
  final TaskEntity task;

  const AddTask({required this.task});

  @override
  List<Object?> get props => [task];
}

class EditTask extends TaskEvent {
  final TaskEntity task;

  const EditTask({required this.task});

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskComplete extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  const ToggleTaskComplete({
    required this.taskId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [taskId, isCompleted];
}

class FilterChanged extends TaskEvent {
  final TaskPriorityFilter priority;
  final TaskStatusFilter status;

  const FilterChanged({
    required this.priority,
    required this.status,
  });

  @override
  List<Object?> get props => [priority, status];
}