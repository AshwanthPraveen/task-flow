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
  ];
}
