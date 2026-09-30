// ============================================================================
// File: delete_task_repository_impl.dart
// Created Date: 30-Sep-2026
// Title: DeleteTaskRepositoryImpl
// Description:
//   Maps API exceptions from the delete task call to failures.
//
// Class:
//   DeleteTaskRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';

import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/features/task_detail/data/datasources/delete_task_remote_data_source.dart';
import 'package:task_flow/features/task_detail/domain/repositories/delete_task_repository.dart';

class DeleteTaskRepositoryImpl implements DeleteTaskRepository {
  const DeleteTaskRepositoryImpl({required this._remoteDataSource});

  final DeleteTaskRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, void>> deleteTask({required int id}) async {
    try {
      await _remoteDataSource.deleteTask(id);
      return const Right(null);
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
