import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthChecking()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    debugPrint(
      '[AuthBloc] dispatching AuthCheckRequested to subscribe to '
      'authStateChanges via emit.forEach...',
    );
    add(const AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await getCurrentUserUseCase();
    if (user != null && user.id.isNotEmpty) {
      debugPrint('[AuthBloc] AuthCheckRequested: user found uid=${user.id}');
      emit(AuthSuccess(user));
    } else {
      debugPrint(
        '[AuthBloc] AuthCheckRequested: no cached user, '
        'staying in $AuthChecking until authStateChanges resolves',
      );
    }

    await emit.forEach(
      getCurrentUserUseCase.authStateChanges,
      onData: (authUser) {
        if (authUser != null && authUser.id.isNotEmpty) {
          debugPrint(
            '[AuthBloc] authStateChanges -> '
            'Authenticated(uid=${authUser.id})',
          );
          return AuthSuccess(authUser);
        }
        debugPrint('[AuthBloc] authStateChanges -> unauth');
        return const AuthInitial();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[AuthBloc] authStateChanges stream error: $error');
        return AuthFailure(error.toString());
      },
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInUseCase(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] SignOutRequested: starting Firebase signOut()...');
    emit(const AuthLoading());
    final result = await signOutUseCase(const NoParams());
    debugPrint('[AuthBloc] SignOutRequested: Firebase signOut() completed');
    result.fold(
      (failure) {
        debugPrint(
          '[AuthBloc] SignOutRequested: emitting AuthFailure '
          '(${failure.message})',
        );
        emit(AuthFailure(failure.message));
      },
      (_) {
        debugPrint(
          '[AuthBloc] SignOutRequested: emitting AuthInitial (unauthenticated)',
        );
        emit(const AuthInitial());
      },
    );
  }
}