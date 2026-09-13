import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager/core/theme/app_theme.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/failures/auth_failure.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/usecase.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart'
    hide AuthFailure;
import 'package:task_manager/features/auth/presentation/pages/login_page.dart';

class _FakeSignInUseCase implements SignInUseCase {
  @override
  Future<Either<AuthFailure, UserEntity>> call(SignInParams params) async =>
      const Right(UserEntity(id: 'sign-in-user'));
}

class _FakeSignUpUseCase implements SignUpUseCase {
  @override
  Future<Either<AuthFailure, UserEntity>> call(SignUpParams params) async =>
      const Right(UserEntity(id: 'sign-up-user'));
}

class _ControlledSignOutUseCase implements SignOutUseCase {
  final Completer<Either<AuthFailure, void>> completer =
      Completer<Either<AuthFailure, void>>();

  @override
  Future<Either<AuthFailure, void>> call(NoParams params) => completer.future;
}

class _FakeGetCurrentUserUseCase implements GetCurrentUserUseCase {
  final UserEntity? currentUser;
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  _FakeGetCurrentUserUseCase({this.currentUser});

  @override
  Future<UserEntity?> call() async => currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  Future<void> closeController() => _controller.close();
}

AuthBloc _buildBloc({
  required _FakeGetCurrentUserUseCase currentUser,
  required _ControlledSignOutUseCase signOut,
}) {
  return AuthBloc(
    signInUseCase: _FakeSignInUseCase(),
    signUpUseCase: _FakeSignUpUseCase(),
    signOutUseCase: signOut,
    getCurrentUserUseCase: currentUser,
  );
}

class _TestBlocHarness {
  final _FakeGetCurrentUserUseCase currentUser;
  final _ControlledSignOutUseCase signOut;
  late final AuthBloc bloc;

  _TestBlocHarness({UserEntity? user})
      : currentUser = _FakeGetCurrentUserUseCase(currentUser: user),
        signOut = _ControlledSignOutUseCase() {
    bloc = _buildBloc(currentUser: currentUser, signOut: signOut);
  }

  Future<void> dispose() async {
    await bloc.close();
    await currentUser.closeController();
  }
}

void main() {
  group('AuthBloc sign-out', () {
    late _TestBlocHarness harness;

    setUp(() {
      harness = _TestBlocHarness(user: const UserEntity(id: 'uid-1'));
    });

    tearDown(() async {
      await harness.dispose();
    });

    test(
      'sign-out completes to AuthInitial and is never stuck in AuthLoading',
      () async {
        await pumpEventQueue();
        expect(harness.bloc.state, isA<AuthSuccess>());

        final emitted = <AuthState>[];
        final sub = harness.bloc.stream.listen(emitted.add);

        harness.bloc.add(const SignOutRequested());
        await pumpEventQueue();
        expect(harness.bloc.state, isA<AuthLoading>());

        harness.signOut.completer.complete(const Right(null));
        await pumpEventQueue();

        expect(harness.bloc.state, isA<AuthInitial>());
        expect(harness.bloc.state, isNot(isA<AuthLoading>()));
        expect(emitted, contains(isA<AuthLoading>()));
        expect(emitted.last, isA<AuthInitial>());

        await sub.cancel();
      },
    );
  });

  testWidgets(
    'login page shows Sign In button after sign-out, not a stuck spinner',
    (tester) async {
      final currentUser = _FakeGetCurrentUserUseCase();
      final signOut = _ControlledSignOutUseCase();
      final bloc = _buildBloc(currentUser: currentUser, signOut: signOut);

      tester.view.physicalSize = const Size(1500, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      bloc.add(const SignOutRequested());
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);

      signOut.completer.complete(const Right(null));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Sign In'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );
}