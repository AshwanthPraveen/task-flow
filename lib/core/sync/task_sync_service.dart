// ============================================================================
// File: task_sync_service.dart
// Created Date: 01-Oct-2026
// Title: TaskSyncService
// Description:
//   Sends the queue of offline changes to the server with POST /sync, oldest
//   change first, in batches.
//   
//   When it runs: at start, when the device goes online, when the WebSocket
//   reconnects, after an offline save, and on a backoff timer while a run
//   fails because the server cannot be reached.
//   
//   Results are matched to changes by local_id (create) or task_id (update,
//   delete). "synced" completes the change; a create swaps the temporary id
//   for server_id.
//   
//   Conflicts: the server answers status "conflict" with its current
//   version. Last write wins: the update is sent once more based on that
//   version. If it conflicts again the task is marked failed.
//   
//   If a whole batch is rejected with a 4xx the changes are sent one by one
//   to find the bad one, which is marked failed instead of retried forever.
//   Network errors, timeouts and 5xx keep the queue and retry later; 401
//   stops the run until the next start().
//   
//   Known limitation: the server does not de-duplicate creates by local_id,
//   so a create whose response was lost may be created twice on retry.
//
// Class:
//   TaskSyncService
// ============================================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:task_flow/core/network/api_exception.dart';
import 'package:task_flow/core/network/connectivity_service.dart';
import 'package:task_flow/core/socket/task_socket_service.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/core/sync/pending_operation.dart';
import 'package:task_flow/core/sync/sync_models.dart';
import 'package:task_flow/core/sync/sync_remote_data_source.dart';
import 'package:task_flow/core/sync/task_local_change_bus.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_local_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/pending_change_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

enum TaskSyncStatus { idle, syncing, waitingToRetry }

enum _Step { next, retryLater, halt }

class _Conflict {
  const _Conflict(this.change, this.serverVersion);

  final PendingChangeModel change;
  final int? serverVersion;
}

class TaskSyncService {
  TaskSyncService({
    required this._localDataSource,
    required this._syncRemoteDataSource,
    required this._connectivity,
    required this._socketService,
    required this._changeBus,
    required this._userDetails,
  });

  static const int _maxBackoffSeconds = 30;
  static const int _batchSize = 50;
  static const Duration _afterSaveDelay = Duration(milliseconds: 500);
  static const String _conflictMessage = 'Changed on another device.';

  final TaskLocalDataSource _localDataSource;
  final SyncRemoteDataSource _syncRemoteDataSource;
  final ConnectivityService _connectivity;
  final TaskSocketService _socketService;
  final TaskLocalChangeBus _changeBus;
  final UserDetails _userDetails;

  final StreamController<TaskSyncStatus> _statusController =
      StreamController<TaskSyncStatus>.broadcast();

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<void>? _reconnectedSubscription;
  StreamSubscription<dynamic>? _localChangeSubscription;
  Timer? _timer;

  bool _started = false;
  bool _isSyncing = false;
  bool _rerunRequested = false;
  int _attempt = 0;
  TaskSyncStatus _status = TaskSyncStatus.idle;

  Stream<TaskSyncStatus> get statuses => _statusController.stream;

  TaskSyncStatus get status => _status;

  /// Starts listening for reasons to sync and runs once. Safe to call twice.
  void start() {
    if (_started) return;
    _started = true;

    _connectivitySubscription = _connectivity.onChanged.listen((online) {
      if (online) requestSync();
    });
    _reconnectedSubscription = _socketService.reconnected.listen(
      (_) => requestSync(),
    );
    _localChangeSubscription = _changeBus.events.listen((_) {
      // A save made while a run is going is picked up by that run's next pass.
      if (_isSyncing) {
        _rerunRequested = true;
      } else {
        requestSync(delay: _afterSaveDelay);
      }
    });

    requestSync();
  }

  /// Stops syncing (call on logout). Queued changes stay in the database.
  void stop() {
    _started = false;
    _timer?.cancel();
    _timer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _reconnectedSubscription?.cancel();
    _reconnectedSubscription = null;
    _localChangeSubscription?.cancel();
    _localChangeSubscription = null;
    _attempt = 0;
    _setStatus(TaskSyncStatus.idle);
  }

  /// Asks for a sync run; repeated calls are merged into one.
  void requestSync({Duration delay = Duration.zero}) {
    if (!_started) return;
    _timer?.cancel();
    _timer = Timer(delay, _run);
  }

  Future<void> _run() async {
    if (!_started) return;
    if (_isSyncing) {
      _rerunRequested = true;
      return;
    }

    _isSyncing = true;
    _setStatus(TaskSyncStatus.syncing);
    _Step outcome = _Step.next;

    try {
      do {
        _rerunRequested = false;
        outcome = await _drainQueue();
      } while (outcome == _Step.next && _rerunRequested && _started);
    } catch (e) {
      // Unexpected (database, malformed response): keep the queue, try later.
      if (kDebugMode) debugPrint('Sync error: $e');
      outcome = _Step.retryLater;
    } finally {
      _isSyncing = false;
    }

    if (!_started) return;

    if (outcome == _Step.retryLater) {
      _scheduleRetry();
    } else {
      _attempt = 0;
      _setStatus(TaskSyncStatus.idle);
    }
  }

  Future<_Step> _drainQueue() async {
    final List<PendingChangeModel> changes = await _localDataSource
        .getPendingChanges();
    if (changes.isEmpty) return _Step.next;

    if (!await _connectivity.isOnline) return _Step.retryLater;

    for (int i = 0; i < changes.length; i += _batchSize) {
      if (!_started) return _Step.halt;

      final List<PendingChangeModel> chunk = changes.sublist(
        i,
        min(i + _batchSize, changes.length),
      );
      final _Step step = await _syncChunk(chunk);
      if (step != _Step.next) return step;
    }
    return _Step.next;
  }

  Future<_Step> _syncChunk(List<PendingChangeModel> chunk) async {
    List<_Conflict> conflicts;
    bool missing;

    try {
      final List<SyncResultModel> results = await _syncRemoteDataSource.sync([
        for (final PendingChangeModel change in chunk)
          SyncOperationModel.fromChange(change),
      ]);
      final outcome = await _applyResults(chunk, results);
      conflicts = outcome.conflicts;
      missing = outcome.missing;
    } on TimeoutApiException {
      return _Step.retryLater;
    } on NetworkException {
      return _Step.retryLater;
    } on ApiException catch (e) {
      return _handleBatchError(chunk, e);
    }

    if (conflicts.isNotEmpty) {
      final _Step step = await _resolveConflicts(conflicts);
      if (step != _Step.next) return step;
    }

    // A change without a result stays queued and is tried again later.
    return missing ? _Step.retryLater : _Step.next;
  }

  Future<_Step> _handleBatchError(
    List<PendingChangeModel> chunk,
    ApiException e,
  ) async {
    final int? code = e.statusCode;

    // No status code, server trouble, throttling: not the changes' fault.
    if (code == null || code >= 500 || code == 408 || code == 429) {
      return _Step.retryLater;
    }
    if (code == 401) return _Step.halt;

    // The whole batch was refused. Send the changes one by one so only the
    // bad one is given up on.
    if (chunk.length > 1) {
      for (final PendingChangeModel change in chunk) {
        final _Step step = await _syncChunk([change]);
        if (step != _Step.next) return step;
      }
      return _Step.next;
    }

    await _reject(chunk.single, e.message);
    return _Step.next;
  }

  Future<({List<_Conflict> conflicts, bool missing})> _applyResults(
    List<PendingChangeModel> chunk,
    List<SyncResultModel> results,
  ) async {
    final List<SyncResultModel?> matched = _match(chunk, results);
    final List<_Conflict> conflicts = <_Conflict>[];
    bool missing = false;

    for (int i = 0; i < chunk.length; i++) {
      final PendingChangeModel change = chunk[i];
      final SyncResultModel? result = matched[i];

      if (result == null) {
        missing = true;
        continue;
      }

      if (result.isConflict && change.operation == PendingOperation.update) {
        conflicts.add(_Conflict(change, result.version));
        continue;
      }

      await _applyResult(change, result);
    }

    return (conflicts: conflicts, missing: missing);
  }

  Future<_Step> _resolveConflicts(List<_Conflict> conflicts) async {
    final List<_Conflict> resendable = <_Conflict>[];
    for (final _Conflict conflict in conflicts) {
      if (conflict.serverVersion == null) {
        await _reject(conflict.change, _conflictMessage);
      } else {
        resendable.add(conflict);
      }
    }
    if (resendable.isEmpty) return _Step.next;

    try {
      final List<PendingChangeModel> changes = [
        for (final _Conflict c in resendable) c.change,
      ];
      final List<SyncResultModel> results = await _syncRemoteDataSource.sync([
        for (final _Conflict c in resendable)
          SyncOperationModel.fromChange(c.change, version: c.serverVersion),
      ]);
      final List<SyncResultModel?> matched = _match(changes, results);

      bool missing = false;
      for (int i = 0; i < changes.length; i++) {
        final SyncResultModel? result = matched[i];
        if (result == null) {
          missing = true;
        } else if (result.isConflict) {
          // Lost the race again: give up on this edit.
          await _reject(changes[i], _conflictMessage);
        } else {
          await _applyResult(changes[i], result);
        }
      }
      return missing ? _Step.retryLater : _Step.next;
    } on TimeoutApiException {
      return _Step.retryLater;
    } on NetworkException {
      return _Step.retryLater;
    } on ApiException catch (e) {
      final int? code = e.statusCode;
      if (code == null || code >= 500 || code == 408 || code == 429) {
        return _Step.retryLater;
      }
      if (code == 401) return _Step.halt;

      for (final _Conflict c in resendable) {
        await _reject(c.change, e.message);
      }
      return _Step.next;
    }
  }

  Future<void> _applyResult(
    PendingChangeModel change,
    SyncResultModel result,
  ) async {
    if (result.isSynced) return _applySuccess(change, result);

    if (result.isNotFound) {
      await _localDataSource.removeTask(change.taskId);
      // A delete of something already gone is finished; for any other change
      // the task was deleted elsewhere, so the UI must drop it.
      if (change.operation != PendingOperation.delete) {
        _changeBus.notifyDeleted(change.taskId);
      }
      return;
    }

    await _reject(change, result.error ?? 'Sync failed (${result.status}).');
  }

  Future<void> _applySuccess(
    PendingChangeModel change,
    SyncResultModel result,
  ) async {
    switch (change.operation) {
      case PendingOperation.create:
        final int? id = result.serverId ?? result.taskId;
        if (id == null) {
          return _reject(change, 'The server did not return an id.');
        }
        final TaskModel server = _buildTask(
          change,
          id: id,
          version: result.version ?? 1,
          local: await _localDataSource.getTask(change.taskId),
        );
        final TaskModel? shown = await _localDataSource.completeCreate(
          change: change,
          serverTask: server,
        );
        if (shown != null) {
          _changeBus.notifyIdRemapped(change.taskId, shown.toEntity());
        }
      case PendingOperation.update:
        final TaskModel server = _buildTask(
          change,
          id: change.taskId,
          version: result.version ?? (change.baseVersion ?? 0) + 1,
          local: await _localDataSource.getTask(change.taskId),
        );
        final TaskModel? shown = await _localDataSource.completeUpdate(
          change: change,
          serverTask: server,
        );
        if (shown != null) _changeBus.notifyUpdated(shown.toEntity());
      case PendingOperation.delete:
        await _localDataSource.removeTask(change.taskId);
    }
  }

  /// /sync only returns ids and versions, so the task is rebuilt from the
  /// values that were sent plus what is stored locally. The next list
  /// refresh brings in the server's own timestamps.
  TaskModel _buildTask(
    PendingChangeModel change, {
    required int id,
    required int version,
    TaskModel? local,
  }) {
    return TaskModel(
      id: id,
      title: change.title ?? local?.title ?? '',
      description: change.description ?? local?.description,
      status: change.status ?? local?.status ?? 'todo',
      createdAt: local?.createdAt ?? change.createdAt,
      updatedAt: DateTime.now(),
      createdBy: local?.createdBy ?? _userDetails.userId ?? 0,
      version: version,
      localId: change.localId ?? local?.localId,
    );
  }

  /// Pairs each change with its result: by local_id for creates, by task_id
  /// for the rest; by position when the counts agree and no key matches.
  List<SyncResultModel?> _match(
    List<PendingChangeModel> changes,
    List<SyncResultModel> results,
  ) {
    final Map<String, SyncResultModel> byKey = {
      for (final SyncResultModel r in results)
        if (r.localId != null) 'c:${r.localId}': r else 't:${r.taskId}': r,
    };

    return [
      for (int i = 0; i < changes.length; i++)
        byKey[_changeKey(changes[i])] ??
            (results.length == changes.length ? results[i] : null),
    ];
  }

  String _changeKey(PendingChangeModel change) {
    return change.operation == PendingOperation.create
        ? 'c:${change.localId}'
        : 't:${change.taskId}';
  }

  /// Gives up on a change the server will never accept.
  Future<void> _reject(PendingChangeModel change, String message) async {
    await _localDataSource.markFailed(change: change, error: message);

    final TaskModel? task = await _localDataSource.getTask(change.taskId);
    if (task != null) _changeBus.notifyUpdated(task.toEntity());
  }

  void _scheduleRetry() {
    final int seconds = min(2 << min(_attempt, 4), _maxBackoffSeconds);
    _attempt++;
    _setStatus(TaskSyncStatus.waitingToRetry);

    _timer?.cancel();
    _timer = Timer(Duration(seconds: seconds), _run);
  }

  void _setStatus(TaskSyncStatus status) {
    if (_status == status) return;
    _status = status;
    _statusController.add(status);
  }
}
