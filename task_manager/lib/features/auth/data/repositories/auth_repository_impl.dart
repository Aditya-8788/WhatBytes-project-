import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AuthFailure, UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthExceptionToFailure(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthExceptionToFailure(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthExceptionToFailure(e));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await _remoteDataSource.getCurrentUser();
    return user;
  }

  AuthFailure _mapAuthExceptionToFailure(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return const AuthFailure('Incorrect password. Please try again.');
      case 'user-not-found':
        return const AuthFailure('No account found with this email.');
      case 'email-already-in-use':
        return const AuthFailure('An account already exists with this email.');
      case 'weak-password':
        return const AuthFailure('Password is too weak. Use at least 6 characters.');
      case 'invalid-email':
        return const AuthFailure('Please enter a valid email address.');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.');
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return const AuthFailure('Network error. Check your connection and try again.');
      default:
        return AuthFailure(e.message ?? 'Authentication failed. Please try again.');
    }
  }
}