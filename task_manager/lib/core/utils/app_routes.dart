import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../di/service_locator.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String tasks = '/tasks';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashPage(),
    login: (_) => BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: const LoginPage(),
        ),
    signup: (_) => BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: const SignUpPage(),
        ),
    tasks: (_) => const TasksPage(),
  };
}