import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class SignUpParams {
  final String email;
  final String password;
  final String? displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

class SignUpUseCase extends UseCase<UserEntity, SignUpParams> {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  @override
  Future<Either<AuthFailure, UserEntity>> call(SignUpParams params) {
    return _repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}