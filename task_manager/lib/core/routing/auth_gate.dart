import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/tasks/presentation/bloc/task_event.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';
import '../di/service_locator.dart';
import '../utils/app_routes.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
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
          (previous is AuthSuccess) != (current is AuthSuccess) ||
          (previous is AuthChecking) != (current is AuthChecking),
      builder: (context, state) {
        debugPrint(
          '[AuthGate] build: authState=${state.runtimeType} '
          '${state is AuthSuccess ? "userId=${state.user.id}" : ""}',
        );
        if (state is AuthSuccess && state.user.id.isNotEmpty) {
          debugPrint(
            '[AuthGate] authenticated with valid uid; '
            'building tasks UI (LoadTasks dispatched by _TaskLauncher)',
          );
          return BlocProvider<TaskBloc>(
            create: (_) => sl<TaskBloc>(),
            child: _TaskLauncher(
              userId: state.user.id,
              child: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (_) => TaskListPage(userId: state.user.id),
                ),
              ),
            ),
          );
        }
        if (state is AuthInitial ||
            state is AuthLoading ||
            state is AuthFailure) {
          return Navigator(
            initialRoute: AppRoutes.login,
            onGenerateRoute: _authRoute,
          );
        }
        return const SplashPage();
      },
    );
  }
}

class _TaskLauncher extends StatefulWidget {
  final String userId;
  final Widget child;

  const _TaskLauncher({required this.userId, required this.child});

  @override
  State<_TaskLauncher> createState() => _TaskLauncherState();
}

class _TaskLauncherState extends State<_TaskLauncher> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      '[AuthGate] _TaskLauncher.initState: dispatching LoadTasks exactly once '
      'for userId="${widget.userId}"',
    );
    context.read<TaskBloc>().add(LoadTasks(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}