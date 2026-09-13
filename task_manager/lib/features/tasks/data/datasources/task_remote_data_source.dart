import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/task_model.dart';

class TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  Future<void> createTask(TaskModel task, String userId) async {
    debugPrint(
      '[TaskRemoteDataSource] createTask: WRITE '
      '${TaskFields.userId}=$userId (field name "${TaskFields.userId}") '
      '-> users/$userId/tasks',
    );
    await _tasksCollection(userId).add({
      ...task.toFirestore(),
      TaskFields.userId: userId,
    });
  }

  Future<void> updateTask(TaskModel task, String userId) async {
    debugPrint(
      '[TaskRemoteDataSource] updateTask: WRITE '
      '${TaskFields.userId}=$userId (field name "${TaskFields.userId}") '
      '-> users/$userId/tasks/${task.id}',
    );
    await _tasksCollection(userId).doc(task.id).set({
      ...task.toFirestore(),
      TaskFields.userId: userId,
    });
  }

  Future<void> deleteTask(String taskId, String userId) async {
    await _tasksCollection(userId).doc(taskId).delete();
  }

  Future<void> toggleComplete(
    String taskId,
    bool isCompleted,
    String userId,
  ) async {
    debugPrint(
      '[TaskRemoteDataSource] toggleComplete: writing '
      '${TaskFields.isCompleted}: $isCompleted on '
      'users/$userId/tasks/$taskId',
    );
    await _tasksCollection(userId).doc(taskId).update({
      TaskFields.isCompleted: isCompleted,
    });
  }

  Stream<List<TaskModel>> getTasks(String userId) {
    debugPrint(
      '[TaskRemoteDataSource] getTasks: READ query filters '
      '${TaskFields.userId} == "$userId" on users/$userId/tasks',
    );
    return _tasksCollection(userId)
        .where(TaskFields.userId, isEqualTo: userId)
        .orderBy(TaskFields.dueDate)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromFirestore).toList());
  }
}