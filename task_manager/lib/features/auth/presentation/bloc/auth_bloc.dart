import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
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

  late final StreamSubscription<UserEntity?> _authStateSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthChecking()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    debugPrint('[AuthBloc] subscribing to authStateChanges...');
    _authStateSubscription = getCurrentUserUseCase.authStateChanges.listen(
      (user) => add(AuthStateChanged(user)),
      onError: (Object error) {
        debugPrint('[AuthBloc] authStateChanges stream error: $error');
      },
    );
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    final user = event.user;
    debugPrint(
      '[AuthBloc] authStateChanged -> '
      '${user != null && user.id.isNotEmpty ? "Authenticated(uid=${user.id})" : "unauth"}',
    );
    if (user != null && user.id.isNotEmpty) {
      emit(AuthSuccess(user));
    } else {
      emit(const AuthInitial());
    }
  }

  @override
  Future<void> close() async {
    await _authStateSubscription.cancel();
    await super.close();
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
    emit(const AuthLoading());
    final result = await signOutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthInitial()),
    );
  }
}