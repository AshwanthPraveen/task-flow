// ============================================================================
// File: auth_repository_impl.dart
// Created Date: 27-Sep-2026
// Title: AuthRepositoryImpl
// Description:
//   Implements AuthRepository. Calls the remote data source, converts the
//   model to an entity and maps exceptions into Failure types.
//
// Class:
//   AuthRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_flow/features/auth/data/models/auth_model.dart';
import 'package:task_flow/features/auth/data/models/login_request_model.dart';
import 'package:task_flow/features/auth/domain/entities/auth_entity.dart';
import 'package:task_flow/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this._remoteDataSource});

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final AuthModel auth = await _remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );
      return Right(auth.toEntity());
    } on TimeoutApiException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
