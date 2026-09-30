// ============================================================================
// File: task_local_change_bus.dart
// Created Date: 01-Oct-2026
// Title: TaskLocalChangeBus
// Description:
//   Tells the UI about task changes made on this device while the server
//   cannot echo them back over the WebSocket (offline saves). Uses the same
//   event type as the socket so blocs can handle both the same way.
//
// Class:
//   TaskLocalChangeBus
// ============================================================================

import 'dart:async';

import 'package:task_flow/core/socket/task_socket_event.dart';
import 'package:task_flow/core/socket/task_socket_event_type.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class TaskLocalChangeBus {
  final StreamController<TaskSocketEvent> _controller =
      StreamController<TaskSocketEvent>.broadcast();

  Stream<TaskSocketEvent> get events => _controller.stream;

  void notifyCreated(TaskEntity task) {
    _controller.add(TaskSocketEvent(TaskSocketEventType.created, task.id, task: task));
  }

  void notifyUpdated(TaskEntity task) {
    _controller.add(TaskSocketEvent(TaskSocketEventType.updated, task.id, task: task));
  }

  void notifyDeleted(int taskId) {
    _controller.add(TaskSocketEvent(TaskSocketEventType.deleted, taskId));
  }

  /// An offline-created task was accepted by the server: [oldId] is its
  /// temporary negative id, [task] carries the real one.
  void notifyIdRemapped(int oldId, TaskEntity task) {
    _controller.add(
      TaskSocketEvent(TaskSocketEventType.idRemapped, oldId, task: task),
    );
  }
}
