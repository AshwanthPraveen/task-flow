// ============================================================================
// File: get_task_detail_repository.dart
// Created Date: 30-Sep-2026
// Title: GetTaskDetailRepository
// Description:
//   Abstract contract for the get task detail operation exposed to the
//   domain layer.
//
// Class:
//   GetTaskDetailRepository
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';

import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

abstract class GetTaskDetailRepository {
  Future<Either<Failure, TaskEntity>> getTaskDetail({required int id});
}
