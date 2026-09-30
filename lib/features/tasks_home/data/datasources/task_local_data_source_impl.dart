// ============================================================================
// File: task_local_data_source_impl.dart
// Created Date: 01-Oct-2026
// Title: TaskLocalDataSourceImpl
// Description:
//   Implements TaskLocalDataSource with Drift. Never overwrites a row that
//   has a pending local change, so offline edits are not lost when fresh
//   server data arrives.
//
// Class:
//   TaskLocalDataSourceImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:drift/drift.dart';

import 'package:task_flow/core/database/app_database.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_list_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_sync_state.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(AppDatabase database) : _database = database;

  final AppDatabase _database;

  @override
  Future<void> upsertTasks(List<TaskModel> tasks) {
    return _database.transaction(() async {
      for (final TaskModel task in tasks) {
        await _upsertIfNotPending(task);
      }
    });
  }

  @override
  Future<void> upsertTask(TaskModel task) {
    return _database.transaction(() => _upsertIfNotPending(task));
  }

  @override
  Future<TaskModel?> getTask(int id) async {
    final TaskRow? row = await (_database.select(
      _database.tasksTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    return row == null ? null : _toModel(row);
  }

  @override
  Future<TaskListModel> getTaskList({
    required int page,
    required int limit,
  }) async {
    final List<TaskRow> rows = await _database.select(_database.tasksTable).get();

    // Offline-created tasks (negative id) first, newest first; then the same
    // order as the server (ascending id).
    rows.sort((a, b) {
      final bool aLocal = a.id < 0;
      final bool bLocal = b.id < 0;
      if (aLocal && bLocal) return b.createdAt.compareTo(a.createdAt);
      if (aLocal) return -1;
      if (bLocal) return 1;
      return a.id.compareTo(b.id);
    });

    final List<TaskModel> items = rows
        .skip((page - 1) * limit)
        .take(limit)
        .map(_toModel)
        .toList();

    return TaskListModel(
      items: items,
      page: page,
      limit: limit,
      total: rows.length,
    );
  }

  @override
  Future<void> clearAll() async {
    await _database.transaction(() async {
      await _database.delete(_database.tasksTable).go();
      await _database.delete(_database.pendingChangesTable).go();
    });
  }

  Future<void> _upsertIfNotPending(TaskModel task) async {
    final TaskRow? existing = await (_database.select(
      _database.tasksTable,
    )..where((t) => t.id.equals(task.id))).getSingleOrNull();

    if (existing != null && existing.syncState != TaskSyncState.synced.name) {
      return;
    }

    await _database
        .into(_database.tasksTable)
        .insertOnConflictUpdate(_toCompanion(task));
  }

  TasksTableCompanion _toCompanion(TaskModel task) {
    return TasksTableCompanion(
      id: Value(task.id),
      title: Value(task.title),
      description: Value(task.description),
      status: Value(task.status),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
      createdBy: Value(task.createdBy),
      version: Value(task.version),
      localId: Value(task.localId),
      syncState: Value(task.syncState.name),
      syncError: const Value(null),
    );
  }

  TaskModel _toModel(TaskRow row) {
    return TaskModel(
      id: row.id,
      title: row.title,
      description: row.description,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      createdBy: row.createdBy,
      version: row.version,
      localId: row.localId,
      syncState: TaskSyncState.values.firstWhere(
        (s) => s.name == row.syncState,
        orElse: () => TaskSyncState.synced,
      ),
    );
  }
}
