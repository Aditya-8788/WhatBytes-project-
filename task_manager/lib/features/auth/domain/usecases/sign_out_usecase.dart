import 'package:dartz/dartz.dart';

import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<Either<AuthFailure, void>> call(NoParams params) {
    return _repository.signOut();
  }
}