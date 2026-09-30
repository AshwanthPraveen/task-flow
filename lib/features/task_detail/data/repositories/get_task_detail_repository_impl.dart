// ============================================================================
// File: get_task_detail_repository_impl.dart
// Created Date: 30-Sep-2026
// Title: GetTaskDetailRepositoryImpl
// Description:
//   Implements GetTaskDetailRepository. Calls the remote data source,
//   converts the model to an entity and maps exceptions into Failure types.
//   Saves the fetched task to the local cache and, when there is no internet,
//   serves the cached task instead.
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
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_sync_state.dart';

class GetTaskDetailRepositoryImpl implements GetTaskDetailRepository {
  const GetTaskDetailRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
  });

  final GetTaskDetailRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, TaskEntity>> getTaskDetail({required int id}) async {
    // Unsynced local changes are newer than the server copy (and a task with a
    // temporary id does not exist on the server yet), so they win.
    final TaskModel? unsynced = await _unsyncedLocal(id);
    if (unsynced != null) return Right(unsynced.toEntity());

    try {
      final TaskModel task = await _remoteDataSource.getTaskDetail(id);
      await _cacheTask(task);
      return Right(task.toEntity());
    } on TimeoutApiException catch (e) {
      return _fromCache(id: id, failure: TimeoutFailure(e.message));
    } on NetworkException catch (e) {
      return _fromCache(id: id, failure: NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  /// Best effort: a cache problem must never break an online fetch.
  Future<TaskModel?> _unsyncedLocal(int id) async {
    try {
      final TaskModel? local = await _localDataSource.getTask(id);
      if (local == null || local.syncState == TaskSyncState.synced) return null;
      return local;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheTask(TaskModel task) async {
    try {
      await _localDataSource.upsertTask(task);
    } catch (_) {}
  }

  /// Returns the cached task, or [failure] when it is not cached.
  Future<Either<Failure, TaskEntity>> _fromCache({
    required int id,
    required Failure failure,
  }) async {
    try {
      final TaskModel? cached = await _localDataSource.getTask(id);
      return cached == null ? Left(failure) : Right(cached.toEntity());
    } catch (_) {
      return Left(failure);
    }
  }
}
