import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../failures/task_failure.dart';
import '../repositories/task_repository.dart';

class ToggleCompleteParams {
  final String taskId;
  final bool isCompleted;
  final String userId;

  const ToggleCompleteParams({
    required this.taskId,
    required this.isCompleted,
    required this.userId,
  });
}

class ToggleCompleteUseCase {
  final TaskRepository _repository;

  ToggleCompleteUseCase(this._repository);

  Future<Either<TaskFailure, void>> call(ToggleCompleteParams params) {
    debugPrint(
      '[ToggleCompleteUseCase] forwarding toggle: '
      'taskId="${params.taskId}" isCompleted=${params.isCompleted} '
      'userId="${params.userId}"',
    );
    return _repository.toggleComplete(
      params.taskId,
      params.isCompleted,
      params.userId,
    );
  }
}