import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const Center(
        child: Icon(
          Icons.task_alt,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }
}