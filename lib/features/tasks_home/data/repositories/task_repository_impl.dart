// ============================================================================
// File: task_repository_impl.dart
// Created Date: 29-Sep-2026
// Title: TaskRepositoryImpl
// Description:
//   Implements TaskRepository. Calls the remote data source, converts the model
//   to an entity and maps exceptions into Failure types. Saves every fetched
//   page to the local cache and, when there is no internet, serves the page
//   from that cache instead.
//
// Class:
//   TaskRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_remote_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_list_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_sync_state.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_list_entity.dart';
import 'package:task_flow/features/tasks_home/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
  });

  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;

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
      await _cacheTasks(tasks);
      return Right((await _withLocalChanges(tasks)).toEntity());
    } on TimeoutApiException catch (e) {
      return _fromCache(
        page: page,
        limit: limit,
        failure: TimeoutFailure(e.message),
      );
    } on NetworkException catch (e) {
      return _fromCache(
        page: page,
        limit: limit,
        failure: NetworkFailure(e.message),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  /// Best effort: a cache problem must never break an online fetch.
  /// Applies changes that are not on the server yet to a server page, so a
  /// refresh (for example right after the socket reconnects) does not make
  /// offline work disappear before it is synced.
  Future<TaskListModel> _withLocalChanges(TaskListModel server) async {
    final List<TaskModel> unsynced;
    try {
      unsynced = await _localDataSource.getUnsyncedTasks();
    } catch (_) {
      return server;
    }
    if (unsynced.isEmpty) return server;

    final Map<int, TaskModel> byId = {
      for (final TaskModel task in unsynced) task.id: task,
    };

    final List<TaskModel> items = [
      for (final TaskModel task in server.items)
        if (byId[task.id]?.syncState != TaskSyncState.pendingDelete)
          byId[task.id] ?? task,
    ];

    final List<TaskModel> created = unsynced.where((t) => t.id < 0).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final int deleted = unsynced
        .where((t) => t.syncState == TaskSyncState.pendingDelete)
        .length;

    return TaskListModel(
      items: server.page == 1 ? [...created, ...items] : items,
      page: server.page,
      limit: server.limit,
      total: server.total + created.length - deleted,
    );
  }

  Future<void> _cacheTasks(TaskListModel tasks) async {
    try {
      await _localDataSource.upsertTasks(tasks.items);
    } catch (_) {}
  }

  /// Returns the cached page, or [failure] when nothing is cached yet.
  Future<Either<Failure, TaskListEntity>> _fromCache({
    required int page,
    required int limit,
    required Failure failure,
  }) async {
    try {
      final TaskListModel cached = await _localDataSource.getTaskList(
        page: page,
        limit: limit,
      );
      if (cached.total == 0) return Left(failure);
      return Right(cached.toEntity());
    } catch (_) {
      return Left(failure);
    }
  }
}
