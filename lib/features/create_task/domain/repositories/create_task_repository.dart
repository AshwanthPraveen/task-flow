// ============================================================================
// File: create_task_repository.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskRepository
// Description:
//   Abstract contract for the create task operation exposed to the domain
//   layer.
//
// Class:
//   CreateTaskRepository
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

abstract class CreateTaskRepository {
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    String status = 'todo',
    String? localId,
  });
}
