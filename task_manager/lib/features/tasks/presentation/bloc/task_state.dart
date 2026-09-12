import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';
import 'task_filter.dart';

sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksLoaded extends TasksState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskPriorityFilter priorityFilter;
  final TaskStatusFilter statusFilter;

  const TasksLoaded({
    required this.allTasks,
    required this.filteredTasks,
    required this.priorityFilter,
    required this.statusFilter,
  });

  TasksLoaded copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskPriorityFilter? priorityFilter,
    TaskStatusFilter? statusFilter,
  }) {
    return TasksLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        priorityFilter,
        statusFilter,
      ];
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskSaveSuccess extends TasksState {
  final bool isEdit;

  const TaskSaveSuccess({required this.isEdit});

  @override
  List<Object?> get props => [isEdit];
}

class TaskOperationFailure extends TasksState {
  final String message;

  const TaskOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}