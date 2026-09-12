import 'package:dartz/dartz.dart';

import '../entities/task.dart';
import '../failures/task_failure.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getTasks(String userId);

  Future<Either<TaskFailure, void>> createTask(TaskEntity task, String userId);

  Future<Either<TaskFailure, void>> updateTask(TaskEntity task, String userId);

  Future<Either<TaskFailure, void>> deleteTask(String taskId, String userId);

  Future<Either<TaskFailure, void>> toggleComplete(
    String taskId,
    bool isCompleted,
    String userId,
  );
}