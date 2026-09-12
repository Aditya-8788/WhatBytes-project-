enum TaskPriority { low, medium, high }

class TaskEntity {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });
}