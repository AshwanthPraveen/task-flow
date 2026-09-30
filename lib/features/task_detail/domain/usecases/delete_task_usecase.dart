// ============================================================================
// File: delete_task_usecase.dart
// Created Date: 30-Sep-2026
// Title: DeleteTaskUseCase
// Description:
//   Use case for deleting a task, with its params.
//
// Class:
//   DeleteTaskUseCase
//   DeleteTaskParams
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/usecase/usecase.dart';
import 'package:task_flow/features/task_detail/domain/repositories/delete_task_repository.dart';

class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  const DeleteTaskUseCase(this._repository);

  final DeleteTaskRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) {
    return _repository.deleteTask(id: params.id);
  }
}

class DeleteTaskParams extends Equatable {
  const DeleteTaskParams({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
