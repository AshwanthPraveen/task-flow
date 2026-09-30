// ============================================================================
// File: get_task_detail_usecase.dart
// Created Date: 30-Sep-2026
// Title: GetTaskDetailUseCase
// Description:
//   Use case that fetches a single task by id through
//   GetTaskDetailRepository.
//
// Class:
//   GetTaskDetailUseCase
//   GetTaskDetailParams
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/usecase/usecase.dart';
import 'package:task_flow/features/task_detail/domain/repositories/get_task_detail_repository.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class GetTaskDetailUseCase implements UseCase<TaskEntity, GetTaskDetailParams> {
  const GetTaskDetailUseCase(this._repository);

  final GetTaskDetailRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(GetTaskDetailParams params) {
    return _repository.getTaskDetail(id: params.id);
  }
}

class GetTaskDetailParams extends Equatable {
  const GetTaskDetailParams({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
