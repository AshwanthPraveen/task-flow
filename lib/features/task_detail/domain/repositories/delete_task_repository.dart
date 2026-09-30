// ============================================================================
// File: delete_task_repository.dart
// Created Date: 30-Sep-2026
// Title: DeleteTaskRepository
// Description:
//   Contract for deleting a task.
//
// Class:
//   DeleteTaskRepository
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';

import 'package:task_flow/core/errors/failures.dart';

abstract class DeleteTaskRepository {
  Future<Either<Failure, void>> deleteTask({required int id});
}
