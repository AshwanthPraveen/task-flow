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
import 'package:task_flow/core/sync/task_local_change_bus.dart';
import 'package:task_flow/features/task_detail/data/datasources/delete_task_remote_data_source.dart';
import 'package:task_flow/features/task_detail/domain/repositories/delete_task_repository.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_sync_state.dart';

class DeleteTaskRepositoryImpl implements DeleteTaskRepository {
  const DeleteTaskRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
    required this._changeBus,
  });

  final DeleteTaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final TaskLocalChangeBus _changeBus;

  @override
  Future<Either<Failure, void>> deleteTask({required int id}) async {
    try {
      if (await _hasUnsyncedChanges(id)) {
        return _deleteOffline(id: id, failure: const UnknownFailure());
      }

      await _remoteDataSource.deleteTask(id);
      await _removeCached(id);
      return const Right(null);
    } on TimeoutApiException catch (e) {
      return _deleteOffline(id: id, failure: TimeoutFailure(e.message));
    } on NetworkException catch (e) {
      return _deleteOffline(id: id, failure: NetworkFailure(e.message));
    } on ApiException catch (e) {
      // Already gone on the server: the goal of the delete is met.
      if (e.statusCode == 404) {
        await _removeCached(id);
        _changeBus.notifyDeleted(id);
        return const Right(null);
      }
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

  Future<void> _removeCached(int id) async {
    try {
      await _localDataSource.removeTask(id);
    } catch (_) {}
  }

  Future<Either<Failure, void>> _deleteOffline({
    required int id,
    required Failure failure,
  }) async {
    try {
      await _localDataSource.deleteTaskLocally(id);
      _changeBus.notifyDeleted(id);
      return const Right(null);
    } catch (_) {
      return Left(failure);
    }
  }
}
