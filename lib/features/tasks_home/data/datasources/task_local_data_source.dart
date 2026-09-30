// ============================================================================
// File: task_local_data_source.dart
// Created Date: 01-Oct-2026
// Title: TaskLocalDataSource
// Description:
//   Contract for reading and writing the local task cache.
//
// Class:
//   TaskLocalDataSource
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/tasks_home/data/models/task_list_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  /// Saves server tasks. Rows with pending local changes are not overwritten.
  Future<void> upsertTasks(List<TaskModel> tasks);

  /// Saves one server task. A row with pending local changes is not overwritten.
  Future<void> upsertTask(TaskModel task);

  Future<TaskModel?> getTask(int id);

  /// One page of the cached tasks, in the same shape as the remote response.
  Future<TaskListModel> getTaskList({required int page, required int limit});

  /// Deletes all cached tasks (used when the session ends).
  Future<void> clearAll();
}
