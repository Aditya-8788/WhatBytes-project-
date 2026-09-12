import 'package:dartz/dartz.dart';

import '../entities/task.dart';
import '../failures/task_failure.dart';
import '../repositories/task_repository.dart';

class CreateTaskParams {
  final TaskEntity task;
  final String userId;

  const CreateTaskParams({
    required this.task,
    required this.userId,
  });
}

class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  Future<Either<TaskFailure, void>> call(CreateTaskParams params) {
    return _repository.createTask(params.task, params.userId);
  }
}