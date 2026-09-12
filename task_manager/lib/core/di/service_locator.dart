import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/tasks/data/datasources/task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/create_task_usecase.dart';
import '../../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/toggle_complete_usecase.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/tasks/domain/usecases/update_task_usecase.dart';

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
      ..registerLazySingleton<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(sl<AuthRepository>()),
      )
      ..registerFactory<AuthBloc>(
        () => AuthBloc(
          signInUseCase: sl<SignInUseCase>(),
          signUpUseCase: sl<SignUpUseCase>(),
          signOutUseCase: sl<SignOutUseCase>(),
          getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        ),
      )
      ..registerLazySingleton<TaskRemoteDataSource>(
        () => TaskRemoteDataSource(sl<FirebaseFirestore>()),
      )
      ..registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(sl<TaskRemoteDataSource>()),
      )
      ..registerLazySingleton<CreateTaskUseCase>(
        () => CreateTaskUseCase(sl<TaskRepository>()),
      )
      ..registerLazySingleton<UpdateTaskUseCase>(
        () => UpdateTaskUseCase(sl<TaskRepository>()),
      )
      ..registerLazySingleton<DeleteTaskUseCase>(
        () => DeleteTaskUseCase(sl<TaskRepository>()),
      )
      ..registerLazySingleton<ToggleCompleteUseCase>(
        () => ToggleCompleteUseCase(sl<TaskRepository>()),
      )
      ..registerLazySingleton<GetTasksUseCase>(
        () => GetTasksUseCase(sl<TaskRepository>()),
      )
      ..registerFactory<TaskBloc>(
        () => TaskBloc(
          getTasksUseCase: sl<GetTasksUseCase>(),
          createTaskUseCase: sl<CreateTaskUseCase>(),
          updateTaskUseCase: sl<UpdateTaskUseCase>(),
          deleteTaskUseCase: sl<DeleteTaskUseCase>(),
          toggleCompleteUseCase: sl<ToggleCompleteUseCase>(),
        ),
      );
  }
}