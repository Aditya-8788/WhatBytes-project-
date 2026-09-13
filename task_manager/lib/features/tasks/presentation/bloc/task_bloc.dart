import 'dart:async';

import 'package:flutter/foundation.dart';
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
  Timer? _initialLoadTimeout;
  List<TaskEntity> _allTasks = const [];
  TasksLoaded? _lastLoaded;
  TaskPriorityFilter _priorityFilter = TaskPriorityFilter.all;
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;

  @override
  Future<void> close() async {
    _clearInitialLoadTimeout();
    await super.close();
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TasksState> emit,
  ) async {
    final userId = event.userId;
    if (userId == null || userId.isEmpty) {
      debugPrint(
        '[TaskBloc] LoadTasks rejected: '
        'userId=${userId == null ? "null" : "empty"}',
      );
      emit(const TasksError('Not authenticated'));
      return;
    }
    debugPrint('[TaskBloc] LoadTasks: loading tasks for userId="$userId"');
    _userId = userId;
    _clearInitialLoadTimeout();
    emit(const TasksLoading());

    _initialLoadTimeout = Timer(const Duration(seconds: 10), () {
      _initialLoadTimeout = null;
      emit(const TasksError('Failed to load tasks — timeout'));
    });

    await emit.forEach(
      getTasksUseCase(GetTasksParams(userId: userId)),
      onData: (tasks) {
        _clearInitialLoadTimeout();
        _allTasks = List.unmodifiable(tasks);
        final loaded = TasksLoaded(
          allTasks: _allTasks,
          filteredTasks: _applyFilters(_allTasks),
          priorityFilter: _priorityFilter,
          statusFilter: _statusFilter,
        );
        _lastLoaded = loaded;
        return loaded;
      },
      onError: (error, stackTrace) {
        _clearInitialLoadTimeout();
        return TasksError(error.toString());
      },
    );
    _clearInitialLoadTimeout();
  }

  void _clearInitialLoadTimeout() {
    _initialLoadTimeout?.cancel();
    _initialLoadTimeout = null;
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
      (failure) => _emitFailure(emit, failure.message),
      (_) => _emitSaveSuccess(emit, isEdit: false),
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
      (failure) => _emitFailure(emit, failure.message),
      (_) => _emitSaveSuccess(emit, isEdit: true),
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
      (failure) => _emitFailure(emit, failure.message),
      (_) {},
    );
  }

  Future<void> _onToggleTaskComplete(
    ToggleTaskComplete event,
    Emitter<TasksState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) {
      debugPrint('[TaskBloc] ToggleTaskComplete skipped: no userId');
      return;
    }
    debugPrint(
      '[TaskBloc] ToggleTaskComplete: taskId="${event.taskId}" '
      'isCompleted=${event.isCompleted}',
    );
    final result = await toggleCompleteUseCase(
      ToggleCompleteParams(
        taskId: event.taskId,
        isCompleted: event.isCompleted,
        userId: userId,
      ),
    );
    result.fold(
      (failure) => _emitFailure(emit, failure.message),
      (_) => debugPrint(
        '[TaskBloc] ToggleTaskComplete persisted: '
        'taskId="${event.taskId}"',
      ),
    );
  }

  void _emitSaveSuccess(Emitter<TasksState> emit, {required bool isEdit}) {
    emit(TaskSaveSuccess(isEdit: isEdit));
    final last = _lastLoaded;
    if (last != null) {
      emit(last);
    }
  }

  void _emitFailure(Emitter<TasksState> emit, String message) {
    emit(TaskOperationFailure(message));
    final last = _lastLoaded;
    if (last != null) {
      emit(last);
    }
  }

  void _onFilterChanged(FilterChanged event, Emitter<TasksState> emit) {
    _priorityFilter = event.priority;
    _statusFilter = event.status;

    final current = state;
    if (current is TasksLoaded) {
      final updated = current.copyWith(
        filteredTasks: _applyFilters(current.allTasks),
        priorityFilter: _priorityFilter,
        statusFilter: _statusFilter,
      );
      _lastLoaded = updated;
      emit(updated);
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