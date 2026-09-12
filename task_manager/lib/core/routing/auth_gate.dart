import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';
import '../di/service_locator.dart';
import '../utils/app_routes.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  Route<void> _authRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => switch (settings.name) {
        AppRoutes.login => const LoginPage(),
        AppRoutes.signup => const SignUpPage(),
        _ => const SplashPage(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          (previous is AuthSuccess) != (current is AuthSuccess),
      builder: (context, state) {
        if (state is AuthSuccess) {
          return BlocProvider<TaskBloc>(
            create: (_) => sl<TaskBloc>(),
            child: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => TaskListPage(userId: state.user.id),
              ),
            ),
          );
        }
        return Navigator(
          initialRoute: AppRoutes.splash,
          onGenerateRoute: _authRoute,
        );
      },
    );
  }
}