import '../../domain/entities/task.dart';

enum TaskPriorityFilter {
  all,
  low,
  medium,
  high,
}

extension TaskPriorityFilterX on TaskPriorityFilter {
  TaskPriority? get priority {
    switch (this) {
      case TaskPriorityFilter.all:
        return null;
      case TaskPriorityFilter.low:
        return TaskPriority.low;
      case TaskPriorityFilter.medium:
        return TaskPriority.medium;
      case TaskPriorityFilter.high:
        return TaskPriority.high;
    }
  }
}

enum TaskStatusFilter {
  all,
  completed,
  incomplete,
}