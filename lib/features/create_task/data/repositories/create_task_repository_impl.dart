// ============================================================================
// File: create_task_repository_impl.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskRepositoryImpl
// Description:
//   Implements CreateTaskRepository. Builds the request (with the logged
//   in user id as client_id and a client-generated local_id), calls the
//   remote data source and maps exceptions into Failure types. When the
//   network is unavailable the task is saved locally and queued for sync.
//
// Class:
//   CreateTaskRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================


import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/core/sync/task_local_change_bus.dart';
import 'package:task_flow/features/create_task/data/datasources/create_task_remote_data_source.dart';
import 'package:task_flow/features/create_task/data/models/create_task_request_model.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/create_task/domain/repositories/create_task_repository.dart';

class CreateTaskRepositoryImpl implements CreateTaskRepository {
  const CreateTaskRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
    required this._changeBus,
    required this._userDetails,
  });

  final CreateTaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final TaskLocalChangeBus _changeBus;
  final UserDetails _userDetails;

  static final Random _random = Random.secure();

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    String status = 'todo',
    String? localId,
  }) async {
    final String cleanTitle = title.trim();
    final String? trimmedDescription = description?.trim();
    final String? cleanDescription =
        (trimmedDescription == null || trimmedDescription.isEmpty)
        ? null
        : trimmedDescription;

    // Generated before the first attempt so a retry of the same task (after
    // a timeout, or when the queue is synced) carries the same local_id.
    final String clientLocalId = localId ?? _generateLocalId();

    try {
      final TaskModel task = await _remoteDataSource.createTask(
        CreateTaskRequestModel(
          title: cleanTitle,
          description: cleanDescription,
          status: status,
          clientId: _userDetails.userId?.toString(),
          localId: clientLocalId,
        ),
      );
      await _cacheTask(task);
      return Right(task.toEntity());
    } on TimeoutApiException catch (e) {
      return _saveOffline(
        title: cleanTitle,
        description: cleanDescription,
        status: status,
        localId: clientLocalId,
        failure: TimeoutFailure(e.message),
      );
    } on NetworkException catch (e) {
      return _saveOffline(
        title: cleanTitle,
        description: cleanDescription,
        status: status,
        localId: clientLocalId,
        failure: NetworkFailure(e.message),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<void> _cacheTask(TaskModel task) async {
    try {
      await _localDataSource.upsertTask(task);
    } catch (_) {}
  }

  /// Keeps the task on the device and queues it for the sync step. Falls back
  /// to the original failure if it cannot be stored.
  Future<Either<Failure, TaskEntity>> _saveOffline({
    required String title,
    required String? description,
    required String status,
    required String localId,
    required Failure failure,
  }) async {
    final int? userId = _userDetails.userId;
    if (userId == null) return Left(failure);

    try {
      final TaskModel saved = await _localDataSource.createPendingTask(
        title: title,
        description: description,
        status: status,
        createdBy: userId,
        localId: localId,
      );
      final TaskEntity entity = saved.toEntity();
      _changeBus.notifyCreated(entity);
      return Right(entity);
    } catch (_) {
      return Left(failure);
    }
  }

  String _generateLocalId() {
    final int now = DateTime.now().microsecondsSinceEpoch;
    final int salt = _random.nextInt(1 << 32);
    return '$now-${salt.toRadixString(16)}';
  }
}
