import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;
    final priorityColor = priorityColorFor(task.priority);

    void handleToggle() {
      debugPrint('[TaskCard] checkbox onTap fired for taskId="${task.id}"');
      onToggle();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: priorityColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: completed ? 0.6 : 1.0,
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: handleToggle,
                  child: _CheckCircle(
                    isCompleted: completed,
                    fillColor: priorityColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  decoration: completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor:
                                      AppColors.textSecondary,
                                ),
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat.yMMMd().format(task.dueDate!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PriorityChip(priority: task.priority),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isCompleted;
  final Color fillColor;

  const _CheckCircle({
    required this.isCompleted,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? fillColor : Colors.white,
        border: Border.all(
          color: isCompleted ? fillColor : AppColors.textSecondary,
          width: 2,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: fillColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : null,
    );
  }
}

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = priorityColorFor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

Color priorityColorFor(TaskPriority priority) => switch (priority) {
      TaskPriority.low => AppColors.success,
      TaskPriority.medium => AppColors.warning,
      TaskPriority.high => AppColors.error,
    };