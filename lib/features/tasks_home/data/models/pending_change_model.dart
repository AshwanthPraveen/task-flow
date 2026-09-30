// ============================================================================
// File: pending_change_model.dart
// Created Date: 01-Oct-2026
// Title: PendingChangeModel
// Description:
//   One entry of the pending_changes queue: a create, update or delete made
//   on this device that the server has not accepted yet.
//
// Class:
//   PendingChangeModel
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/core/database/app_database.dart';
import 'package:task_flow/core/sync/pending_operation.dart';

class PendingChangeModel {
  const PendingChangeModel({
    required this.id,
    required this.operation,
    required this.taskId,
    required this.localId,
    required this.title,
    required this.description,
    required this.status,
    required this.baseVersion,
    required this.createdAt,
  });

  final int id;
  final PendingOperation operation;
  final int taskId;
  final String? localId;
  final String? title;
  final String? description;
  final String? status;
  final int? baseVersion;
  final DateTime createdAt;

  factory PendingChangeModel.fromRow(PendingChangeRow row) {
    return PendingChangeModel(
      id: row.id,
      operation: PendingOperation.values.firstWhere(
        (o) => o.name == row.operation,
        orElse: () => PendingOperation.update,
      ),
      taskId: row.taskId,
      localId: row.localId,
      title: row.title,
      description: row.description,
      status: row.status,
      baseVersion: row.baseVersion,
      createdAt: row.createdAt,
    );
  }
}
