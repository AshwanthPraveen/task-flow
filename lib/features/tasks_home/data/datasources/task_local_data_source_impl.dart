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
import 'package:task_flow/core/sync/pending_operation.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/pending_change_model.dart';
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
    final TaskRow? row = await _findRow(id);
    if (row == null || row.syncState == TaskSyncState.pendingDelete.name) {
      return null;
    }

    return _toModel(row);
  }

  @override
  Future<TaskListModel> getTaskList({
    required int page,
    required int limit,
  }) async {
    final List<TaskRow> rows =
        await (_database.select(_database.tasksTable)..where(
              (t) => t.syncState.equals(TaskSyncState.pendingDelete.name).not(),
            ))
            .get();

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

  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final List<TaskRow> rows = await (_database.select(
      _database.tasksTable,
    )..where((t) => t.syncState.equals(TaskSyncState.synced.name).not())).get();

    return rows.map(_toModel).toList();
  }

  @override
  Future<TaskModel> createPendingTask({
    required String title,
    required String? description,
    required String status,
    required int createdBy,
    required String localId,
  }) {
    return _database.transaction(() async {
      final DateTime now = DateTime.now();
      final int tempId = await _nextTempId();

      await _database
          .into(_database.tasksTable)
          .insert(
            TasksTableCompanion(
              id: Value(tempId),
              title: Value(title),
              description: Value(description),
              status: Value(status),
              createdAt: Value(now),
              updatedAt: Value(now),
              createdBy: Value(createdBy),
              version: const Value(0),
              localId: Value(localId),
              syncState: Value(TaskSyncState.pendingCreate.name),
              syncError: const Value(null),
            ),
          );

      await _database
          .into(_database.pendingChangesTable)
          .insert(
            PendingChangesTableCompanion(
              operation: Value(PendingOperation.create.name),
              taskId: Value(tempId),
              localId: Value(localId),
              title: Value(title),
              description: Value(description),
              status: Value(status),
              createdAt: Value(now),
            ),
          );

      return _toModel((await _findRow(tempId))!);
    });
  }

  @override
  Future<TaskModel?> updatePendingTask({
    required int id,
    required String title,
    required String? description,
    required String status,
  }) {
    return _database.transaction(() async {
      final TaskRow? row = await _findRow(id);
      if (row == null || row.syncState == TaskSyncState.pendingDelete.name) {
        return null;
      }

      // A task the server never saw keeps its queued "create"; the edit is
      // merged into it instead of adding a second change.
      final bool isLocalOnly = id < 0;
      final PendingOperation operation = isLocalOnly
          ? PendingOperation.create
          : PendingOperation.update;
      final TaskSyncState nextState = isLocalOnly
          ? TaskSyncState.pendingCreate
          : TaskSyncState.pendingUpdate;
      final DateTime now = DateTime.now();

      await (_database.update(
        _database.tasksTable,
      )..where((t) => t.id.equals(id))).write(
        TasksTableCompanion(
          title: Value(title),
          description: Value(description),
          status: Value(status),
          updatedAt: Value(now),
          syncState: Value(nextState.name),
          syncError: const Value(null),
        ),
      );

      final List<PendingChangeRow> queued =
          await (_database.select(_database.pendingChangesTable)..where(
                (c) => c.taskId.equals(id) & c.operation.equals(operation.name),
              ))
              .get();

      if (queued.isNotEmpty) {
        // Keep the original baseVersion so the server can detect conflicts.
        await (_database.update(
          _database.pendingChangesTable,
        )..where((c) => c.id.equals(queued.first.id))).write(
          PendingChangesTableCompanion(
            title: Value(title),
            description: Value(description),
            status: Value(status),
          ),
        );
      } else {
        await _database
            .into(_database.pendingChangesTable)
            .insert(
              PendingChangesTableCompanion(
                operation: Value(operation.name),
                taskId: Value(id),
                localId: Value(row.localId),
                title: Value(title),
                description: Value(description),
                status: Value(status),
                baseVersion: Value(isLocalOnly ? null : row.version),
                createdAt: Value(now),
              ),
            );
      }

      return _toModel((await _findRow(id))!);
    });
  }

  @override
  Future<void> deleteTaskLocally(int id) {
    return _database.transaction(() async {
      final TaskRow? row = await _findRow(id);
      if (row == null) return;

      // A queued create/update is pointless once the task is deleted.
      await _deletePendingChanges(id);

      if (id < 0) {
        await (_database.delete(
          _database.tasksTable,
        )..where((t) => t.id.equals(id))).go();
        return;
      }

      final DateTime now = DateTime.now();

      await (_database.update(
        _database.tasksTable,
      )..where((t) => t.id.equals(id))).write(
        TasksTableCompanion(
          syncState: Value(TaskSyncState.pendingDelete.name),
          syncError: const Value(null),
          updatedAt: Value(now),
        ),
      );

      await _database
          .into(_database.pendingChangesTable)
          .insert(
            PendingChangesTableCompanion(
              operation: Value(PendingOperation.delete.name),
              taskId: Value(id),
              localId: Value(row.localId),
              baseVersion: Value(row.version),
              createdAt: Value(now),
            ),
          );
    });
  }

  @override
  Future<void> removeTask(int id) {
    return _database.transaction(() async {
      await _deletePendingChanges(id);
      await (_database.delete(
        _database.tasksTable,
      )..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<List<PendingChangeModel>> getPendingChanges() async {
    final List<PendingChangeRow> rows =
        await (_database.select(_database.pendingChangesTable)
              ..orderBy([(c) => OrderingTerm.asc(c.id)]))
            .get();

    return rows.map(PendingChangeModel.fromRow).toList();
  }

  @override
  Future<TaskModel?> completeCreate({
    required PendingChangeModel change,
    required TaskModel serverTask,
  }) {
    return _database.transaction(() async {
      final PendingChangeRow? current = await _findChange(change.id);

      // Deleted while the create was being sent (this removed the queued
      // create): the server now has the task, so it is deleted there too.
      if (current == null) {
        await _database
            .into(_database.tasksTable)
            .insertOnConflictUpdate(
              _toCompanion(serverTask).copyWith(
                syncState: Value(TaskSyncState.pendingDelete.name),
              ),
            );
        await _queueDelete(
          serverTask.id,
          serverTask.localId,
          serverTask.version,
        );
        return null;
      }

      await _deleteChange(change.id);
      await (_database.delete(
        _database.tasksTable,
      )..where((t) => t.id.equals(change.taskId))).go();

      final bool editedMeanwhile = _isEdited(current, change);

      await _database
          .into(_database.tasksTable)
          .insertOnConflictUpdate(
            _toCompanion(serverTask).copyWith(
              title: editedMeanwhile ? Value(current.title!) : null,
              description: editedMeanwhile ? Value(current.description) : null,
              status: editedMeanwhile ? Value(current.status!) : null,
              syncState: Value(
                editedMeanwhile
                    ? TaskSyncState.pendingUpdate.name
                    : TaskSyncState.synced.name,
              ),
            ),
          );

      if (editedMeanwhile) {
        await _database
            .into(_database.pendingChangesTable)
            .insert(
              PendingChangesTableCompanion(
                operation: Value(PendingOperation.update.name),
                taskId: Value(serverTask.id),
                localId: Value(serverTask.localId),
                title: Value(current.title),
                description: Value(current.description),
                status: Value(current.status),
                baseVersion: Value(serverTask.version),
                createdAt: Value(DateTime.now()),
              ),
            );
      }

      return _toModel((await _findRow(serverTask.id))!);
    });
  }

  @override
  Future<TaskModel?> completeUpdate({
    required PendingChangeModel change,
    required TaskModel serverTask,
  }) {
    return _database.transaction(() async {
      final PendingChangeRow? current = await _findChange(change.id);
      final TaskRow? row = await _findRow(change.taskId);

      // Deleted while the update was being sent: nothing to show any more.
      if (current == null || row == null) {
        if (current != null) await _deleteChange(change.id);
        return null;
      }

      // Edited again while the update was being sent: that edit stays queued,
      // now based on the version the server just produced.
      if (_isEdited(current, change)) {
        await (_database.update(_database.pendingChangesTable)
              ..where((c) => c.id.equals(change.id)))
            .write(
              PendingChangesTableCompanion(
                baseVersion: Value(serverTask.version),
              ),
            );
        await (_database.update(
          _database.tasksTable,
        )..where((t) => t.id.equals(change.taskId))).write(
          TasksTableCompanion(
            version: Value(serverTask.version),
            syncState: Value(TaskSyncState.pendingUpdate.name),
          ),
        );
        return _toModel((await _findRow(change.taskId))!);
      }

      await _deleteChange(change.id);
      await _database
          .into(_database.tasksTable)
          .insertOnConflictUpdate(_toCompanion(serverTask));

      return _toModel((await _findRow(change.taskId))!);
    });
  }

  @override
  Future<void> markFailed({
    required PendingChangeModel change,
    required String error,
  }) {
    return _database.transaction(() async {
      await _deleteChange(change.id);

      final TaskRow? row = await _findRow(change.taskId);
      if (row == null) return;

      // A change that failed to delete leaves the task visible again.
      await (_database.update(
        _database.tasksTable,
      )..where((t) => t.id.equals(change.taskId))).write(
        TasksTableCompanion(
          syncState: Value(TaskSyncState.failed.name),
          syncError: Value(error),
        ),
      );
    });
  }

  Future<PendingChangeRow?> _findChange(int id) {
    return (_database.select(
      _database.pendingChangesTable,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> _deleteChange(int id) async {
    await (_database.delete(
      _database.pendingChangesTable,
    )..where((c) => c.id.equals(id))).go();
  }

  Future<void> _queueDelete(int taskId, String? localId, int version) async {
    await _database
        .into(_database.pendingChangesTable)
        .insert(
          PendingChangesTableCompanion(
            operation: Value(PendingOperation.delete.name),
            taskId: Value(taskId),
            localId: Value(localId),
            baseVersion: Value(version),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  /// True when the queued change no longer matches what was sent.
  bool _isEdited(PendingChangeRow current, PendingChangeModel sent) {
    return current.title != sent.title ||
        current.description != sent.description ||
        current.status != sent.status;
  }

  Future<TaskRow?> _findRow(int id) {
    return (_database.select(
      _database.tasksTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> _deletePendingChanges(int taskId) async {
    await (_database.delete(
      _database.pendingChangesTable,
    )..where((c) => c.taskId.equals(taskId))).go();
  }

  /// Offline-created tasks use negative ids, counting down from -1.
  Future<int> _nextTempId() async {
    final TaskRow? lowest =
        await (_database.select(_database.tasksTable)
              ..orderBy([(t) => OrderingTerm.asc(t.id)])
              ..limit(1))
            .getSingleOrNull();

    final int lowestId = lowest?.id ?? 0;
    return (lowestId < 0 ? lowestId : 0) - 1;
  }

  Future<void> _upsertIfNotPending(TaskModel task) async {
    final TaskRow? existing = await _findRow(task.id);

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
