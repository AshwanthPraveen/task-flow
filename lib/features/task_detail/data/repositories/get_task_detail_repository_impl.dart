// ============================================================================
// File: get_task_detail_repository_impl.dart
// Created Date: 30-Sep-2026
// Title: GetTaskDetailRepositoryImpl
// Description:
//   Implements GetTaskDetailRepository. Calls the remote data source,
//   converts the model to an entity and maps exceptions into Failure types.
//
// Class:
//   GetTaskDetailRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/features/task_detail/data/datasources/get_task_detail_remote_data_source.dart';
import 'package:task_flow/features/task_detail/domain/repositories/get_task_detail_repository.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class GetTaskDetailRepositoryImpl implements GetTaskDetailRepository {
  const GetTaskDetailRepositoryImpl({required this._remoteDataSource});

  final GetTaskDetailRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, TaskEntity>> getTaskDetail({required int id}) async {
    try {
      final TaskModel task = await _remoteDataSource.getTaskDetail(id);
      return Right(task.toEntity());
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
