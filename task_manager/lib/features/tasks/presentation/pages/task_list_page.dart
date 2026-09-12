import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_filter.dart';
import '../bloc/task_state.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

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
    if (widget.userId.isNotEmpty) {
      context.read<TaskBloc>().add(LoadTasks(userId: widget.userId));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTaskSheet({TaskEntity? task}) {
    final bloc = context.read<TaskBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<TaskBloc>.value(
        value: bloc,
        child: TaskFormSheet(
          initialTask: task,
          onSave: (value) {
            bloc.add(task == null ? AddTask(task: value) : EditTask(task: value));
          },
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
              decoration: const InputDecoration(
                hintText: 'Search tasks',
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
          TasksLoading() => const Center(child: CircularProgressIndicator()),
          TasksError() => _buildError(state.message),
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
      return _buildEmpty(hasFilters: false);
    }
    if (visible.isEmpty) {
      return _buildEmpty(hasFilters: true);
    }

    final sections = _groupTasks(visible);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    '${section.tasks.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final task in section.tasks)
            Dismissible(
              key: ValueKey('task-${task.id}'),
              direction: DismissDirection.endToStart,
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
              onDismissed: (_) => context
                  .read<TaskBloc>()
                  .add(DeleteTask(taskId: task.id)),
              child: TaskCard(
                task: task,
                onToggle: () => context.read<TaskBloc>().add(
                      ToggleTaskComplete(
                        taskId: task.id,
                        isCompleted: task.isCompleted,
                      ),
                    ),
                onTap: () => _showTaskSheet(task: task),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ],
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

  Widget _buildEmpty({required bool hasFilters}) {
    return Center(
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
            child: const Icon(
              Icons.task_alt,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No matching tasks' : 'No tasks yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search'
                : 'Tap + to add your first task',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
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
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous is AuthLoading && current is AuthInitial,
      listener: (context, state) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showTaskSheet,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}