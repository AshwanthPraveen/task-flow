// ============================================================================
// File: get_tasks_usecase.dart
// Created Date: 29-Sep-2026
// Title: GetTasksUseCase
// Description:
//   Use case that fetches one page of tasks through TaskRepository.
//
// Class:
//   GetTasksUseCase
//   GetTasksParams
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/usecase/usecase.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_list_entity.dart';
import 'package:task_flow/features/tasks_home/domain/repositories/task_repository.dart';

class GetTasksUseCase implements UseCase<TaskListEntity, GetTasksParams> {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskListEntity>> call(GetTasksParams params) {
    return _repository.getTasks(page: params.page, limit: params.limit);
  }
}

class GetTasksParams extends Equatable {
  const GetTasksParams({this.page = 1, this.limit = 20});

  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}
