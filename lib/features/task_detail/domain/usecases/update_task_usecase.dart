// ============================================================================
// File: update_task_usecase.dart
// Created Date: 30-Sep-2026
// Title: UpdateTaskUseCase
// Description:
//   Use case for updating a task, with its params.
//
// Class:
//   UpdateTaskUseCase
//   UpdateTaskParams
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/usecase/usecase.dart';
import 'package:task_flow/features/task_detail/domain/repositories/update_task_repository.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class UpdateTaskUseCase implements UseCase<TaskEntity, UpdateTaskParams> {
  const UpdateTaskUseCase(this._repository);

  final UpdateTaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) {
    return _repository.updateTask(
      id: params.id,
      title: params.title,
      description: params.description,
      status: params.status,
      version: params.version,
    );
  }
}

class UpdateTaskParams extends Equatable {
  const UpdateTaskParams({
    required this.id,
    required this.title,
    required this.status,
    required this.version,
    this.description,
  });

  final int id;
  final String title;
  final String? description;
  final String status;
  final int version;

  @override
  List<Object?> get props => [id, title, description, status, version];
}
