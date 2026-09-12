import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksParams {
  final String userId;

  const GetTasksParams({required this.userId});
}

class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase(this._repository);

  Stream<List<TaskEntity>> call(GetTasksParams params) {
    return _repository.getTasks(params.userId);
  }
}