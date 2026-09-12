import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/task.dart';
import '../../domain/failures/task_failure.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<TaskEntity>> getTasks(String userId) {
    return _remoteDataSource.getTasks(userId);
  }

  @override
  Future<Either<TaskFailure, void>> createTask(
    TaskEntity task,
    String userId,
  ) async {
    try {
      await _remoteDataSource.createTask(TaskModel.fromEntity(task), userId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<TaskFailure, void>> updateTask(
    TaskEntity task,
    String userId,
  ) async {
    try {
      await _remoteDataSource.updateTask(TaskModel.fromEntity(task), userId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<TaskFailure, void>> deleteTask(
    String taskId,
    String userId,
  ) async {
    try {
      await _remoteDataSource.deleteTask(taskId, userId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<TaskFailure, void>> toggleComplete(
    String taskId,
    bool isCompleted,
    String userId,
  ) async {
    try {
      await _remoteDataSource.toggleComplete(taskId, isCompleted, userId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  TaskFailure _mapExceptionToFailure(Exception e) {
    if (e is FirebaseException) {
      return TaskFailure(
        e.message ?? 'An unexpected error occurred',
      );
    }
    return const TaskFailure('Something went wrong. Please try again.');
  }
}