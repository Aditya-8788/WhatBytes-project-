import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/task_filter.dart';

class FilterSheet extends StatefulWidget {
  final TaskPriorityFilter initialPriority;
  final TaskStatusFilter initialStatus;
  final void Function(
    TaskPriorityFilter priority,
    TaskStatusFilter status,
  ) onApply;

  const FilterSheet({
    super.key,
    required this.initialPriority,
    required this.initialStatus,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TaskPriorityFilter _priority = widget.initialPriority;
  late TaskStatusFilter _status = widget.initialStatus;

  void _apply() {
    widget.onApply(_priority, _status);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _priority = TaskPriorityFilter.all;
      _status = TaskStatusFilter.all;
    });
    _apply();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Filter Tasks',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                TaskPriorityFilter.values
                    .map(
                      (filter) => _ChoiceChip<TaskPriorityFilter>(
                        value: filter,
                        selected: _priority,
                        label: _priorityLabel(filter),
                        onSelected: (value) =>
                            setState(() => _priority = value),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                TaskStatusFilter.values
                    .map(
                      (filter) => _ChoiceChip<TaskStatusFilter>(
                        value: filter,
                        selected: _status,
                        label: _statusLabel(filter),
                        onSelected: (value) => setState(() => _status = value),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              TextButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _apply,
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _priorityLabel(TaskPriorityFilter filter) {
    return switch (filter) {
      TaskPriorityFilter.all => 'All',
      TaskPriorityFilter.low => 'Low',
      TaskPriorityFilter.medium => 'Medium',
      TaskPriorityFilter.high => 'High',
    };
  }

  String _statusLabel(TaskStatusFilter filter) {
    return switch (filter) {
      TaskStatusFilter.all => 'All',
      TaskStatusFilter.completed => 'Completed',
      TaskStatusFilter.incomplete => 'Incomplete',
    };
  }
}

class _ChoiceChip<T> extends StatelessWidget {
  final T value;
  final T selected;
  final String label;
  final ValueChanged<T> onSelected;

  const _ChoiceChip({
    required this.value,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.primarySoft,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (_) => onSelected(value),
    );
  }
}