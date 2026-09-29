// ============================================================================
// File: task_repository_impl.dart
// Created Date: 29-Sep-2026
// Title: TaskRepositoryImpl
// Description:
//   Implements TaskRepository. Calls the remote data source, converts the model
//   to an entity and maps exceptions into Failure types.
//
// Class:
//   TaskRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_remote_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_list_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_list_entity.dart';
import 'package:task_flow/features/tasks_home/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({required this._remoteDataSource});

  final TaskRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, TaskListEntity>> getTasks({
    required int page,
    required int limit,
  }) async {
    try {
      final TaskListModel tasks = await _remoteDataSource.getTasks(
        page: page,
        limit: limit,
      );
      return Right(tasks.toEntity());
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
