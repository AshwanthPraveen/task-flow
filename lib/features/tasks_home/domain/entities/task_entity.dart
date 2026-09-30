// ============================================================================
// File: task_entity.dart
// Created Date: 29-Sep-2026
// Title: TaskEntity
// Description:
//   Domain entity representing a single task.
//
// Class:
//   TaskEntity
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/features/tasks_home/domain/entities/task_sync_state.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.version,
    required this.localId,
    this.syncState = TaskSyncState.synced,
  });

  final int id;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdBy;
  final int version;
  final String? localId;
  final TaskSyncState syncState;

  bool get isPendingSync =>
      syncState == TaskSyncState.pendingCreate ||
      syncState == TaskSyncState.pendingUpdate;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    createdAt,
    updatedAt,
    createdBy,
    version,
    localId,
    syncState,
  ];
}
