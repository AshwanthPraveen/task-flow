// ============================================================================
// File: task_model.dart
// Created Date: 29-Sep-2026
// Title: TaskModel
// Description:
//   Data model for a task in the tasks API response. Handles JSON parsing and
//   converts to TaskEntity. Also carries the local sync state when the task
//   is read from the local database.
//
// Class:
//   TaskModel
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_sync_state.dart';

class TaskModel {
  const TaskModel({
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as int,
      version: json['version'] as int,
      localId: json['local_id'] as String?,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      version: version,
      localId: localId,
      syncState: syncState,
    );
  }
}
