import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(
          Icons.task_alt,
          size: 80,
          color: AppColors.primary,
        ),
      ),
    );
  }
}