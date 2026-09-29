// ============================================================================
// File: task_repository.dart
// Created Date: 29-Sep-2026
// Title: TaskRepository
// Description:
//   Abstract contract for task operations exposed to the domain layer.
//
// Class:
//   TaskRepository
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';

import 'package:task_flow/features/tasks_home/domain/entities/task_list_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, TaskListEntity>> getTasks({
    required int page,
    required int limit,
  });
}
