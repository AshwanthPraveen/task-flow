// ============================================================================
// File: injection.dart
// Created Date: 27-Sep-2026
// Title: Injection
// Description:
//   Sets up dependency injection using GetIt. Each feature has its own
//   registration method; add new features by creating a _registerXxx method
//   and calling it from setupDependencies.
//
// Class:
//   Injection
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/socket/task_socket_service.dart';
import 'package:task_flow/core/database/app_database.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source_impl.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_flow/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:task_flow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_flow/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_bloc.dart';
import 'package:task_flow/features/create_task/data/datasources/create_task_remote_data_source.dart';
import 'package:task_flow/features/create_task/data/datasources/create_task_remote_data_source_impl.dart';
import 'package:task_flow/features/create_task/data/repositories/create_task_repository_impl.dart';
import 'package:task_flow/features/create_task/domain/repositories/create_task_repository.dart';
import 'package:task_flow/features/create_task/domain/usecases/create_task_usecase.dart';
import 'package:task_flow/features/create_task/presentation/bloc/create_task_bloc.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_remote_data_source.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_remote_data_source_impl.dart';
import 'package:task_flow/features/tasks_home/data/repositories/task_repository_impl.dart';
import 'package:task_flow/features/tasks_home/domain/repositories/task_repository.dart';
import 'package:task_flow/features/tasks_home/domain/usecases/get_tasks_usecase.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_bloc.dart';
import 'package:task_flow/features/task_detail/data/datasources/get_task_detail_remote_data_source.dart';
import 'package:task_flow/features/task_detail/data/datasources/get_task_detail_remote_data_source_impl.dart';
import 'package:task_flow/features/task_detail/data/repositories/get_task_detail_repository_impl.dart';
import 'package:task_flow/features/task_detail/domain/repositories/get_task_detail_repository.dart';
import 'package:task_flow/features/task_detail/domain/usecases/get_task_detail_usecase.dart';
import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_bloc.dart';
import 'package:task_flow/features/task_detail/data/datasources/delete_task_remote_data_source.dart';
import 'package:task_flow/features/task_detail/data/datasources/delete_task_remote_data_source_impl.dart';
import 'package:task_flow/features/task_detail/data/datasources/update_task_remote_data_source.dart';
import 'package:task_flow/features/task_detail/data/datasources/update_task_remote_data_source_impl.dart';
import 'package:task_flow/features/task_detail/data/repositories/delete_task_repository_impl.dart';
import 'package:task_flow/features/task_detail/data/repositories/update_task_repository_impl.dart';
import 'package:task_flow/features/task_detail/domain/repositories/delete_task_repository.dart';
import 'package:task_flow/features/task_detail/domain/repositories/update_task_repository.dart';
import 'package:task_flow/features/task_detail/domain/usecases/delete_task_usecase.dart';
import 'package:task_flow/features/task_detail/domain/usecases/update_task_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await _registerExternal();
  _registerCore();
  _registerDatabase();
  _registerAuth();
  _registerTasksHome();
  _registerCreateTask();
  _registerTaskDetail();
  _registerSocket();
}

// ---------------------------------------------------------------------------
// External
// ---------------------------------------------------------------------------
Future<void> _registerExternal() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
}

// ---------------------------------------------------------------------------
// Core
// ---------------------------------------------------------------------------
void _registerCore() {
  getIt.registerLazySingleton<UserDetails>(
    () => UserDetails(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      authHeaderProvider: () async {
        final String? token =
            getIt<UserDetails>().accessToken; // adjust to your API
        return (token == null || token.isEmpty) ? null : 'Bearer $token';
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Feature: Auth
// ---------------------------------------------------------------------------
void _registerAuth() {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  // Blocs
  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(
      loginUseCase: getIt<LoginUseCase>(),
      userDetails: getIt<UserDetails>(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Feature: Tasks Home
// ---------------------------------------------------------------------------
void _registerTasksHome() {
  // Data sources
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: getIt<TaskRemoteDataSource>(),
      localDataSource: getIt<TaskLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetTasksUseCase>(
    () => GetTasksUseCase(getIt<TaskRepository>()),
  );

  // Blocs
  getIt.registerFactory<TasksBloc>(
    () => TasksBloc(
      getTasksUseCase: getIt<GetTasksUseCase>(),
      socketService: getIt<TaskSocketService>(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Feature: Create Task
// ---------------------------------------------------------------------------
void _registerCreateTask() {
  // Data sources
  getIt.registerLazySingleton<CreateTaskRemoteDataSource>(
    () => CreateTaskRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<CreateTaskRepository>(
    () => CreateTaskRepositoryImpl(
      remoteDataSource: getIt<CreateTaskRemoteDataSource>(),
      userDetails: getIt<UserDetails>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<CreateTaskUseCase>(
    () => CreateTaskUseCase(getIt<CreateTaskRepository>()),
  );

  // Blocs
  getIt.registerFactory<CreateTaskBloc>(
    () => CreateTaskBloc(createTaskUseCase: getIt<CreateTaskUseCase>()),
  );
}

// ---------------------------------------------------------------------------
// Feature: Task Detail
// ---------------------------------------------------------------------------
void _registerTaskDetail() {
  // Data sources
  getIt.registerLazySingleton<GetTaskDetailRemoteDataSource>(
    () => GetTaskDetailRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<UpdateTaskRemoteDataSource>(
    () => UpdateTaskRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DeleteTaskRemoteDataSource>(
    () => DeleteTaskRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<GetTaskDetailRepository>(
    () => GetTaskDetailRepositoryImpl(
      remoteDataSource: getIt<GetTaskDetailRemoteDataSource>(),
      localDataSource: getIt<TaskLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<UpdateTaskRepository>(
    () => UpdateTaskRepositoryImpl(
      remoteDataSource: getIt<UpdateTaskRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<DeleteTaskRepository>(
    () => DeleteTaskRepositoryImpl(
      remoteDataSource: getIt<DeleteTaskRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetTaskDetailUseCase>(
    () => GetTaskDetailUseCase(getIt<GetTaskDetailRepository>()),
  );
  getIt.registerLazySingleton<UpdateTaskUseCase>(
    () => UpdateTaskUseCase(getIt<UpdateTaskRepository>()),
  );
  getIt.registerLazySingleton<DeleteTaskUseCase>(
    () => DeleteTaskUseCase(getIt<DeleteTaskRepository>()),
  );

  // Blocs
  getIt.registerFactory<TaskDetailBloc>(
    () => TaskDetailBloc(
      getTaskDetailUseCase: getIt<GetTaskDetailUseCase>(),
      updateTaskUseCase: getIt<UpdateTaskUseCase>(),
      deleteTaskUseCase: getIt<DeleteTaskUseCase>(),
      socketService: getIt<TaskSocketService>(),
    ),
  );
}

void _registerSocket() {
  getIt.registerLazySingleton<TaskSocketService>(
    () => TaskSocketService(getIt<UserDetails>()),
  );
}

void _registerDatabase() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(getIt<AppDatabase>()),
  );
}
