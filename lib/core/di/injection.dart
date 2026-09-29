// ============================================================================
// File: injection.dart
// Created Date: 27-Sep-2026
// Title: Injection
// Description:
//   Sets up dependency injection using GetIt.
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

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register repositories, use cases, blocs, and services here.

  // External
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Core
  getIt.registerLazySingleton<UserDetails>(
    () => UserDetails(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

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
