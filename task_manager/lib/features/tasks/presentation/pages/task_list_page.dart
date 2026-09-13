import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_filter.dart';
import '../bloc/task_state.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_page.dart';

class TaskListPage extends StatefulWidget {
  final String userId;

  const TaskListPage({super.key, required this.userId});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEditTask({TaskEntity? task}) {
    final bloc = context.read<TaskBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<TaskBloc>.value(
          value: bloc,
          child: AddEditTaskPage(initialTask: task),
        ),
      ),
    );
  }

  void _openFilterSheet() {
    final bloc = context.read<TaskBloc>();
    final current = bloc.state;
    if (current is! TasksLoaded) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<TaskBloc>.value(
        value: bloc,
        child: FilterSheet(
          initialPriority: current.priorityFilter,
          initialStatus: current.statusFilter,
          onApply: (priority, status) =>
              bloc.add(FilterChanged(priority: priority, status: status)),
        ),
      ),
    );
  }

  void _openSearch() {
    setState(() => _isSearching = true);
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  void _handleMenu(String value) {
    switch (value) {
      case 'reset':
        context.read<TaskBloc>().add(
              const FilterChanged(
                priority: TaskPriorityFilter.all,
                status: TaskStatusFilter.all,
              ),
            );
      case 'signout':
        context.read<AuthBloc>().add(const SignOutRequested());
    }
  }

  List<({String title, List<TaskEntity> tasks})> _groupTasks(
    List<TaskEntity> tasks,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final grouped = <String, List<TaskEntity>>{
      'Today': [],
      'Tomorrow': [],
      'This Week': [],
      'Other': [],
    };

    for (final task in tasks) {
      final due = task.dueDate;
      if (due == null) {
        grouped['Other']!.add(task);
        continue;
      }
      final day = DateTime(due.year, due.month, due.day);
      if (day == today) {
        grouped['Today']!.add(task);
      } else if (day == tomorrow) {
        grouped['Tomorrow']!.add(task);
      } else if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) {
        grouped['This Week']!.add(task);
      } else {
        grouped['Other']!.add(task);
      }
    }

    return grouped.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => (title: entry.key, tasks: entry.value))
        .toList();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 20,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Search tasks',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            )
          : const Text('Tasks'),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close search',
            onPressed: _closeSearch,
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _openSearch,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter',
            onPressed: _openFilterSheet,
          ),
        ],
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Menu',
          onSelected: _handleMenu,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.filter_alt_off_outlined,
                      size: 20, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text('Reset filters'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text('Sign out'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<TaskBloc, TasksState>(
      builder: (context, state) {
        return switch (state) {
          TasksInitial() => const SizedBox.shrink(),
          TasksLoading() => const _TaskLoadingPlaceholder(),
          TasksError() => _buildError(state.message),
          TaskSaveSuccess() => const SizedBox.shrink(),
          TaskOperationFailure() => const SizedBox.shrink(),
          TasksLoaded() => _buildLoaded(state),
        };
      },
    );
  }

  Widget _buildLoaded(TasksLoaded state) {
    final query = _searchController.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? state.filteredTasks
        : state.filteredTasks
              .where(
                (task) =>
                    task.title.toLowerCase().contains(query) ||
                    task.description.toLowerCase().contains(query),
              )
              .toList();

    if (state.allTasks.isEmpty) {
      return _buildEmpty(
        icon: Icons.task_alt,
        title: 'No tasks yet',
        subtitle: 'Tap + to add your first task',
        actionLabel: 'Add Task',
        onAction: () => _openAddEditTask(),
      );
    }
    if (visible.isEmpty) {
      if (query.isNotEmpty) {
        return _buildEmpty(
          icon: Icons.search_off,
          title: 'No results for "$query"',
          subtitle: 'Try a different search term',
          actionLabel: 'Clear Search',
          actionIcon: Icons.close,
          onAction: _closeSearch,
        );
      }
      return _buildEmpty(
        icon: Icons.filter_alt_off_outlined,
        title: 'No matching tasks',
        subtitle: 'Try adjusting your filters',
        actionLabel: 'Clear Filters',
        actionIcon: Icons.filter_alt_off_outlined,
        onAction: () => context.read<TaskBloc>().add(
              const FilterChanged(
                priority: TaskPriorityFilter.all,
                status: TaskStatusFilter.all,
              ),
            ),
      );
    }

    final sections = _groupTasks(visible);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
                ? 2
                : 1;
        final useGrid = columns > 1;
        final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 16.0;
        final spacing = 16.0;
        final contentWidth =
            constraints.maxWidth - horizontalPadding * 2 - spacing;
        final cardWidth = !useGrid
            ? double.infinity
            : (contentWidth - spacing * (columns - 1)) / columns;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            100,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            for (final section in sections) ...[
              _buildSectionHeader(
                title: section.title,
                count: section.tasks.length,
              ),
              if (useGrid)
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final task in section.tasks)
                      SizedBox(
                        width: cardWidth,
                        child: _buildDismissible(task),
                      ),
                  ],
                )
              else
                for (final task in section.tasks) _buildDismissible(task),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({required String title, required int count}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissible(TaskEntity task) {
    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(task),
      onDismissed: (_) =>
          context.read<TaskBloc>().add(DeleteTask(taskId: task.id)),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: TaskCard(
        task: task,
        onToggle: () {
          debugPrint(
            '[TaskListPage] dispatching ToggleTaskComplete '
            'taskId="${task.id}" new isCompleted=${!task.isCompleted}',
          );
          context.read<TaskBloc>().add(
                ToggleTaskComplete(
                  taskId: task.id,
                  isCompleted: !task.isCompleted,
                ),
              );
        },
        onTap: () => _openAddEditTask(task: task),
      ),
    );
  }

  Future<bool> _confirmDelete(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    IconData actionIcon = Icons.add,
    VoidCallback? onAction,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon, size: 18),
                  label: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<TaskBloc>()
                  .add(LoadTasks(userId: widget.userId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TasksState>(
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
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openAddEditTask(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TaskLoadingPlaceholder extends StatelessWidget {
  const _TaskLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                size: 44,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your tasks...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}