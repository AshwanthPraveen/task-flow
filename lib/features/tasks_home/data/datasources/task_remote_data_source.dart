// ============================================================================
// File: task_remote_data_source.dart
// Created Date: 29-Sep-2026
// Title: TaskRemoteDataSource
// Description:
//   Abstract contract for task related remote API calls.
//
// Class:
//   TaskRemoteDataSource
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/tasks_home/data/models/task_list_model.dart';

abstract class TaskRemoteDataSource {
  Future<TaskListModel> getTasks({required int page, required int limit});
}
