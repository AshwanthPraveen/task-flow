// ============================================================================
// File: create_task_usecase.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskUseCase
// Description:
//   Use case that creates a task with title, description and status
//   through CreateTaskRepository.
//
// Class:
//   CreateTaskUseCase
//   CreateTaskParams
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/usecase/usecase.dart';
import 'package:task_flow/features/create_task/domain/repositories/create_task_repository.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class CreateTaskUseCase implements UseCase<TaskEntity, CreateTaskParams> {
  const CreateTaskUseCase(this._repository);

  final CreateTaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) {
    return _repository.createTask(
      title: params.title,
      description: params.description,
      status: params.status,
      localId: params.localId,
    );
  }
}

class CreateTaskParams extends Equatable {
  const CreateTaskParams({
    required this.title,
    this.description,
    this.status = 'todo',
    this.localId,
  });

  final String title;
  final String? description;
  final String status;
  final String? localId;

  @override
  List<Object?> get props => [title, description, status, localId];
}
