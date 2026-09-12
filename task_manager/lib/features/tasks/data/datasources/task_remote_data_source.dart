import 'package:cloud_firestore/cloud_firestore.dart';

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
    await _tasksCollection(userId).add(task.toFirestore());
  }

  Future<void> updateTask(TaskModel task, String userId) async {
    await _tasksCollection(userId).doc(task.id).set(task.toFirestore());
  }

  Future<void> deleteTask(String taskId, String userId) async {
    await _tasksCollection(userId).doc(taskId).delete();
  }

  Future<void> toggleComplete(
    String taskId,
    bool isCompleted,
    String userId,
  ) async {
    await _tasksCollection(userId)
        .doc(taskId)
        .update({'isCompleted': !isCompleted});
  }

  Stream<List<TaskModel>> getTasks(String userId) {
    return _tasksCollection(userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromFirestore).toList());
  }
}