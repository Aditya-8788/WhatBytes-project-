import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class AddEditTaskPage extends StatefulWidget {
  final TaskEntity? initialTask;

  const AddEditTaskPage({super.key, this.initialTask});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.initialTask?.title ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.initialTask?.description ?? '');
  late DateTime? _dueDate = widget.initialTask?.dueDate;
  late TaskPriority _priority =
      widget.initialTask?.priority ?? TaskPriority.medium;

  bool get _isEditing => widget.initialTask != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final task = TaskEntity(
      id: widget.initialTask?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      isCompleted: widget.initialTask?.isCompleted ?? false,
    );
    context.read<TaskBloc>().add(
          _isEditing ? EditTask(task: task) : AddTask(task: task),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TasksState>(
      listenWhen: (previous, current) => current is TaskSaveSuccess,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: BlocListener<TaskBloc, TasksState>(
        listenWhen: (previous, current) => current is TaskOperationFailure,
        listener: (context, state) {
          final failure = state as TaskOperationFailure;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Task' : 'New Task'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: !_isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: const Color(0xFFF4F1FB),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _pickDate,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _dueDate == null
                                      ? 'No due date'
                                      : DateFormat.yMMMd()
                                          .format(_dueDate!),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _dueDate == null
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () =>
                                      setState(() => _dueDate = null),
                                ),
                            ],
                          ),
                        ),
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
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<TaskPriority>(
                        segments: const [
                          ButtonSegment(
                            value: TaskPriority.low,
                            label: Text('Low'),
                            icon: Icon(Icons.arrow_downward, size: 16),
                          ),
                          ButtonSegment(
                            value: TaskPriority.medium,
                            label: Text('Medium'),
                            icon: Icon(Icons.remove, size: 16),
                          ),
                          ButtonSegment(
                            value: TaskPriority.high,
                            label: Text('High'),
                            icon: Icon(Icons.arrow_upward, size: 16),
                          ),
                        ],
                        selected: {_priority},
                        onSelectionChanged: (selection) =>
                            setState(() => _priority = selection.first),
                        showSelectedIcon: false,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Add Task',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}