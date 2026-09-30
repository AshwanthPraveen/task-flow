// ============================================================================
// File: task_socket_event.dart
// Created Date: 01-Oct-2026
// Title: TaskSocketEvent
// Description:
//   A parsed WebSocket task event. Created and updated events carry the full
//   task; deleted events may carry only the task id.
//
// Class:
//   TaskSocketEvent
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/core/socket/task_socket_event_type.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class TaskSocketEvent extends Equatable {
  const TaskSocketEvent(TaskSocketEventType type, int taskId, {this._task})
    : _type = type,
      _taskId = taskId;

  final TaskSocketEventType _type;
  final int _taskId;
  final TaskEntity? _task;

  TaskSocketEventType get type => _type;
  int get taskId => _taskId;
  TaskEntity? get task => _task;

  @override
  List<Object?> get props => <Object?>[_type, _taskId, _task];
}
