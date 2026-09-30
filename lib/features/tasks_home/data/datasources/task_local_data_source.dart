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

import 'package:task_flow/features/tasks_home/data/models/pending_change_model.dart';
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

  /// Tasks that differ from the server (pending create/update/delete, failed).
  Future<List<TaskModel>> getUnsyncedTasks();

  /// Saves a task created offline under a temporary negative id and queues a
  /// "create" change, in one transaction.
  Future<TaskModel> createPendingTask({
    required String title,
    required String? description,
    required String status,
    required int createdBy,
    required String localId,
  });

  /// Applies an edit locally and queues (or merges into) the pending change.
  /// Returns null when the task is not in the local database.
  Future<TaskModel?> updatePendingTask({
    required int id,
    required String title,
    required String? description,
    required String status,
  });

  /// Deletes a task locally. A task the server never saw is removed outright;
  /// any other task is hidden and a "delete" change is queued.
  Future<void> deleteTaskLocally(int id);

  /// Removes a task and its queued changes (server confirmed the delete).
  Future<void> removeTask(int id);

  /// The queued changes, oldest first.
  Future<List<PendingChangeModel>> getPendingChanges();

  /// The server accepted a queued "create": swaps the temporary id for the
  /// real one and drops the change. Returns the task to show, or null when
  /// the task was deleted while the create was being sent (a "delete" for the
  /// real id is queued instead). An edit made meanwhile is queued as an
  /// "update" on top of the new version.
  Future<TaskModel?> completeCreate({
    required PendingChangeModel change,
    required TaskModel serverTask,
  });

  /// The server accepted a queued "update". Returns the task to show, or null
  /// when it was deleted meanwhile. An edit made while the update was being
  /// sent stays queued on top of the new version.
  Future<TaskModel?> completeUpdate({
    required PendingChangeModel change,
    required TaskModel serverTask,
  });

  /// Gives up on a change the server will not accept: the change leaves the
  /// queue and the task is marked failed with [error].
  Future<void> markFailed({
    required PendingChangeModel change,
    required String error,
  });
}
