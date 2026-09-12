import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    sl
      ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
      ..registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
      )
      ..registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(sl<FirebaseAuth>()),
      )
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
      )
      ..registerLazySingleton<SignUpUseCase>(
        () => SignUpUseCase(sl<AuthRepository>()),
      )
      ..registerLazySingleton<SignInUseCase>(
        () => SignInUseCase(sl<AuthRepository>()),
      )
      ..registerLazySingleton<SignOutUseCase>(
        () => SignOutUseCase(sl<AuthRepository>()),
      )
      ..registerFactory<AuthBloc>(
        () => AuthBloc(
          signInUseCase: sl<SignInUseCase>(),
          signUpUseCase: sl<SignUpUseCase>(),
          signOutUseCase: sl<SignOutUseCase>(),
        ),
      );
  }
}