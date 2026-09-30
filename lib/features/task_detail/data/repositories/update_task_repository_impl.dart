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
import 'package:task_flow/features/task_detail/data/datasources/update_task_remote_data_source.dart';
import 'package:task_flow/features/task_detail/data/models/update_task_request_model.dart';
import 'package:task_flow/features/task_detail/domain/repositories/update_task_repository.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class UpdateTaskRepositoryImpl implements UpdateTaskRepository {
  const UpdateTaskRepositoryImpl({required this._remoteDataSource});

  final UpdateTaskRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, TaskEntity>> updateTask({
    required int id,
    required String title,
    required String status,
    required int version,
    String? description,
  }) async {
    try {
      final String? trimmed = description?.trim();
      final TaskModel task = await _remoteDataSource.updateTask(
        id,
        UpdateTaskRequestModel(
          title: title.trim(),
          description: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
          status: status,
          version: version,
        ),
      );
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
