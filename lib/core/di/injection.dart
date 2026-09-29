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
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_flow/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:task_flow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_flow/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_bloc.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_remote_data_source.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_remote_data_source_impl.dart';
import 'package:task_flow/features/tasks_home/data/repositories/task_repository_impl.dart';
import 'package:task_flow/features/tasks_home/domain/repositories/task_repository.dart';
import 'package:task_flow/features/tasks_home/domain/usecases/get_tasks_usecase.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await _registerExternal();
  _registerCore();
  _registerAuth();
  _registerTasksHome();
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
    () => TaskRepositoryImpl(remoteDataSource: getIt<TaskRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton<GetTasksUseCase>(
    () => GetTasksUseCase(getIt<TaskRepository>()),
  );

  // Blocs
  getIt.registerFactory<TasksBloc>(
    () => TasksBloc(getTasksUseCase: getIt<GetTasksUseCase>()),
  );
}
