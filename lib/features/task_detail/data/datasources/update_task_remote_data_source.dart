// ============================================================================
// File: update_task_remote_data_source.dart
// Created Date: 30-Sep-2026
// Title: UpdateTaskRemoteDataSource
// Description:
//   Contract for calling the update task API.
//
// Class:
//   UpdateTaskRemoteDataSource
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/task_detail/data/models/update_task_request_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

abstract class UpdateTaskRemoteDataSource {
  Future<TaskModel> updateTask(int id, UpdateTaskRequestModel request);
}
