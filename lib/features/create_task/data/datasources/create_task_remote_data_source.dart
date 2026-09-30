// ============================================================================
// File: create_task_remote_data_source.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskRemoteDataSource
// Description:
//   Abstract contract for the create task remote API call.
//
// Class:
//   CreateTaskRemoteDataSource
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/create_task/data/models/create_task_request_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

abstract class CreateTaskRemoteDataSource {
  Future<TaskModel> createTask(CreateTaskRequestModel request);
}
