// ============================================================================
// File: sync_models.dart
// Created Date: 01-Oct-2026
// Title: SyncOperationModel / SyncResultModel
// Description:
//   Request and response items of POST /sync.
//   Server statuses seen so far: "synced" and "conflict".
//
// Class:
//   SyncOperationModel, SyncResultModel
// ============================================================================

import 'package:task_flow/core/sync/pending_operation.dart';
import 'package:task_flow/features/tasks_home/data/models/pending_change_model.dart';

/// One entry of the "changes" array.
class SyncOperationModel {
  const SyncOperationModel({
    required this.operation,
    this.localId,
    this.taskId,
    this.title,
    this.description,
    this.status,
    this.version,
  });

  final String operation;
  final String? localId;
  final int? taskId;
  final String? title;
  final String? description;
  final String? status;
  final int? version;

  /// [version] overrides the version the change was based on (used to resend
  /// an update on top of the server's current version after a conflict).
  factory SyncOperationModel.fromChange(
    PendingChangeModel change, {
    int? version,
  }) {
    switch (change.operation) {
      case PendingOperation.create:
        return SyncOperationModel(
          operation: change.operation.name,
          localId: change.localId,
          title: change.title,
          description: change.description,
          status: change.status,
        );
      case PendingOperation.update:
        return SyncOperationModel(
          operation: change.operation.name,
          taskId: change.taskId,
          title: change.title,
          description: change.description,
          status: change.status,
          version: version ?? change.baseVersion,
        );
      case PendingOperation.delete:
        return SyncOperationModel(
          operation: change.operation.name,
          taskId: change.taskId,
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'local_id': localId,
      'task_id': taskId,
      'title': title,
      'description': description,
      'status': status,
      'version': version,
    };
  }
}

/// One entry of the "results" array.
class SyncResultModel {
  const SyncResultModel({
    required this.localId,
    required this.serverId,
    required this.taskId,
    required this.status,
    required this.version,
    required this.error,
  });

  final String? localId;
  final int? serverId;
  final int? taskId;
  final String status;
  final int? version;
  final String? error;

  factory SyncResultModel.fromJson(Map<String, dynamic> json) {
    return SyncResultModel(
      localId: json['local_id'] as String?,
      serverId: json['server_id'] as int?,
      taskId: json['task_id'] as int?,
      status: (json['status'] as String?) ?? '',
      version: json['version'] as int?,
      error: json['error'] as String?,
    );
  }

  bool get isSynced => status.toLowerCase() == 'synced';

  bool get isConflict => status.toLowerCase() == 'conflict';

  /// The task no longer exists on the server (status text not confirmed).
  bool get isNotFound {
    final String text = '$status ${error ?? ''}'.toLowerCase();
    return text.contains('not_found') ||
        text.contains('not found') ||
        text.contains('notfound');
  }
}
