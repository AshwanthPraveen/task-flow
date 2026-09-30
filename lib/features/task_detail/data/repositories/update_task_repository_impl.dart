// ============================================================================
// File: update_task_repository_impl.dart
// Created Date: 30-Sep-2026
// Title: UpdateTaskRepositoryImpl
// Description:
//   Maps the update task model to an entity and API exceptions to failures.
//
// Class:
//   UpdateTaskRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================


import 'package:dartz/dartz.dart';

import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/core/sync/task_local_change_bus.dart';
import 'package:task_flow/features/task_detail/data/datasources/update_task_remote_data_source.dart';
import 'package:task_flow/features/task_detail/data/models/update_task_request_model.dart';
import 'package:task_flow/features/task_detail/domain/repositories/update_task_repository.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_sync_state.dart';

class UpdateTaskRepositoryImpl implements UpdateTaskRepository {
  const UpdateTaskRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
    required this._changeBus,
  });

  final UpdateTaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final TaskLocalChangeBus _changeBus;

  @override
  Future<Either<Failure, TaskEntity>> updateTask({
    required int id,
    required String title,
    required String status,
    required int version,
    String? description,
  }) async {
    final String cleanTitle = title.trim();
    final String? trimmed = description?.trim();
    final String? cleanDescription = (trimmed == null || trimmed.isEmpty)
        ? null
        : trimmed;

    try {
      // A task with unsynced changes (or one the server has never seen) must
      // not be sent with a stale version: the edit joins the queue instead.
      if (await _hasUnsyncedChanges(id)) {
        return _saveOffline(
          id: id,
          title: cleanTitle,
          description: cleanDescription,
          status: status,
          failure: const UnknownFailure(),
        );
      }

      final TaskModel task = await _remoteDataSource.updateTask(
        id,
        UpdateTaskRequestModel(
          title: cleanTitle,
          description: cleanDescription,
          status: status,
          version: version,
        ),
      );
      await _cacheTask(task);
      return Right(task.toEntity());
    } on TimeoutApiException catch (e) {
      return _saveOffline(
        id: id,
        title: cleanTitle,
        description: cleanDescription,
        status: status,
        failure: TimeoutFailure(e.message),
      );
    } on NetworkException catch (e) {
      return _saveOffline(
        id: id,
        title: cleanTitle,
        description: cleanDescription,
        status: status,
        failure: NetworkFailure(e.message),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<bool> _hasUnsyncedChanges(int id) async {
    if (id < 0) return true;
    try {
      final TaskModel? local = await _localDataSource.getTask(id);
      return local != null && local.syncState != TaskSyncState.synced;
    } catch (_) {
      return false;
    }
  }

  Future<void> _cacheTask(TaskModel task) async {
    try {
      await _localDataSource.upsertTask(task);
    } catch (_) {}
  }

  Future<Either<Failure, TaskEntity>> _saveOffline({
    required int id,
    required String title,
    required String? description,
    required String status,
    required Failure failure,
  }) async {
    try {
      final TaskModel? saved = await _localDataSource.updatePendingTask(
        id: id,
        title: title,
        description: description,
        status: status,
      );
      if (saved == null) return Left(failure);

      final TaskEntity entity = saved.toEntity();
      _changeBus.notifyUpdated(entity);
      return Right(entity);
    } catch (_) {
      return Left(failure);
    }
  }
}
