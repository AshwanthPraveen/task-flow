// ============================================================================
// File: task_list_model.dart
// Created Date: 29-Sep-2026
// Title: TaskListModel
// Description:
//   Data model for the paginated tasks API response. Parses items, page, limit
//   and total from JSON and converts to TaskListEntity.
//
// Class:
//   TaskListModel
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_list_entity.dart';

class TaskListModel {
  const TaskListModel({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<TaskModel> items;
  final int page;
  final int limit;
  final int total;

  factory TaskListModel.fromJson(Map<String, dynamic> json) {
    return TaskListModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
    );
  }

  TaskListEntity toEntity() {
    return TaskListEntity(
      items: items.map((task) => task.toEntity()).toList(),
      page: page,
      limit: limit,
      total: total,
    );
  }
}
