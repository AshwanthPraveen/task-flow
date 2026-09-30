// ============================================================================
// File: update_task_repository.dart
// Created Date: 30-Sep-2026
// Title: UpdateTaskRepository
// Description:
//   Contract for updating a task.
//
// Class:
//   UpdateTaskRepository
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';

import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

abstract class UpdateTaskRepository {
  Future<Either<Failure, TaskEntity>> updateTask({
    required int id,
    required String title,
    required String status,
    required int version,
    String? description,
  });
}
