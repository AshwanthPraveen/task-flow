// ============================================================================
// File: task_list_entity.dart
// Created Date: 29-Sep-2026
// Title: TaskListEntity
// Description:
//   Domain entity for one page of tasks with pagination details (page, limit,
//   total) and a hasMore flag for load-more.
//
// Class:
//   TaskListEntity
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class TaskListEntity extends Equatable {
  const TaskListEntity({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<TaskEntity> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => page * limit < total;

  @override
  List<Object?> get props => [items, page, limit, total];
}
