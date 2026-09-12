import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_complete_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_filter.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TasksState> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ToggleCompleteUseCase toggleCompleteUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleCompleteUseCase,
  }) : super(const TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<EditTask>(_onEditTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskComplete>(_onToggleTaskComplete);
    on<FilterChanged>(_onFilterChanged);
  }

  String? _userId;
  StreamSubscription<List<TaskEntity>>? _tasksSubscription;
  List<TaskEntity> _allTasks = const [];
  TaskPriorityFilter _priorityFilter = TaskPriorityFilter.all;
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;

  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    await super.close();
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TasksState> emit,
  ) async {
    _userId = event.userId;
    await _tasksSubscription?.cancel();
    emit(const TasksLoading());

    _tasksSubscription = getTasksUseCase(
      GetTasksParams(userId: event.userId),
    ).listen(
      (tasks) {
        _allTasks = List.unmodifiable(tasks);
        emit(TasksLoaded(
          allTasks: _allTasks,
          filteredTasks: _applyFilters(_allTasks),
          priorityFilter: _priorityFilter,
          statusFilter: _statusFilter,
        ));
      },
      onError: (Object error) {
        emit(const TasksError('Failed to load tasks. Please try again.'));
      },
    );
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    final result = await createTaskUseCase(
      CreateTaskParams(task: event.task, userId: userId),
    );
    result.fold(
      (failure) => emit(TasksError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onEditTask(EditTask event, Emitter<TasksState> emit) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    final result = await updateTaskUseCase(
      UpdateTaskParams(task: event.task, userId: userId),
    );
    result.fold(
      (failure) => emit(TasksError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TasksState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    final result = await deleteTaskUseCase(
      DeleteTaskParams(taskId: event.taskId, userId: userId),
    );
    result.fold(
      (failure) => emit(TasksError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onToggleTaskComplete(
    ToggleTaskComplete event,
    Emitter<TasksState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    final result = await toggleCompleteUseCase(
      ToggleCompleteParams(
        taskId: event.taskId,
        isCompleted: event.isCompleted,
        userId: userId,
      ),
    );
    result.fold(
      (failure) => emit(TasksError(failure.message)),
      (_) {},
    );
  }

  void _onFilterChanged(FilterChanged event, Emitter<TasksState> emit) {
    _priorityFilter = event.priority;
    _statusFilter = event.status;

    final current = state;
    if (current is TasksLoaded) {
      emit(current.copyWith(
        filteredTasks: _applyFilters(current.allTasks),
        priorityFilter: _priorityFilter,
        statusFilter: _statusFilter,
      ));
    }
  }

  List<TaskEntity> _applyFilters(List<TaskEntity> tasks) {
    final priority = _priorityFilter.priority;

    final filtered = tasks.where((task) {
      final matchesPriority = priority == null || task.priority == priority;
      final matchesStatus = switch (_statusFilter) {
        TaskStatusFilter.all => true,
        TaskStatusFilter.completed => task.isCompleted,
        TaskStatusFilter.incomplete => !task.isCompleted,
      };
      return matchesPriority && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) {
        return 0;
      }
      if (a.dueDate == null) {
        return 1;
      }
      if (b.dueDate == null) {
        return -1;
      }
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return filtered;
  }
}