import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../failures/auth_failure.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<AuthFailure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, void>> signOut();

  Future<UserEntity?> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}