// ============================================================================
// File: get_task_detail_remote_data_source.dart
// Created Date: 30-Sep-2026
// Title: GetTaskDetailRemoteDataSource
// Description:
//   Abstract contract for the get task detail remote API call.
//
// Class:
//   GetTaskDetailRemoteDataSource
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

abstract class GetTaskDetailRemoteDataSource {
  Future<TaskModel> getTaskDetail(int id);
}
