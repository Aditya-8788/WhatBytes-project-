import 'package:dartz/dartz.dart';

import '../entities/task.dart';
import '../failures/task_failure.dart';
import '../repositories/task_repository.dart';

class UpdateTaskParams {
  final TaskEntity task;
  final String userId;

  const UpdateTaskParams({
    required this.task,
    required this.userId,
  });
}

class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  Future<Either<TaskFailure, void>> call(UpdateTaskParams params) {
    return _repository.updateTask(params.task, params.userId);
  }
}