// ============================================================================
// File: create_task_repository_impl.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskRepositoryImpl
// Description:
//   Implements CreateTaskRepository. Builds the request (with the logged
//   in user id as client_id), calls the remote data source, converts the
//   model to an entity and maps exceptions into Failure types.
//
// Class:
//   CreateTaskRepositoryImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/features/create_task/data/datasources/create_task_remote_data_source.dart';
import 'package:task_flow/features/create_task/data/models/create_task_request_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/create_task/domain/repositories/create_task_repository.dart';

class CreateTaskRepositoryImpl implements CreateTaskRepository {
  const CreateTaskRepositoryImpl({
    required this._remoteDataSource,
    required this._userDetails,
  });

  final CreateTaskRemoteDataSource _remoteDataSource;
  final UserDetails _userDetails;

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    String status = 'todo',
    String? localId,
  }) async {
    try {
      final String? trimmedDescription = description?.trim();

      final TaskModel task = await _remoteDataSource.createTask(
        CreateTaskRequestModel(
          title: title.trim(),
          description:
              (trimmedDescription == null || trimmedDescription.isEmpty)
              ? null
              : trimmedDescription,
          status: status,
          clientId: _userDetails.userId?.toString(),
          localId: localId,
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
