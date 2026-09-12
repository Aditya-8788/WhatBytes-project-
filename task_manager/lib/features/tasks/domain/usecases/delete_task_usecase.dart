import 'package:dartz/dartz.dart';

import '../failures/task_failure.dart';
import '../repositories/task_repository.dart';

class DeleteTaskParams {
  final String taskId;
  final String userId;

  const DeleteTaskParams({
    required this.taskId,
    required this.userId,
  });
}

class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<Either<TaskFailure, void>> call(DeleteTaskParams params) {
    return _repository.deleteTask(params.taskId, params.userId);
  }
}