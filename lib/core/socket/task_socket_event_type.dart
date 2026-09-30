// ============================================================================
// File: task_socket_event_type.dart
// Created Date: 01-Oct-2026
// Title: TaskSocketEventType
// Description:
//   Kinds of task events the server can push over the WebSocket.
//
// Class:
//   TaskSocketEventType
//
// Author: Ashwanth V Praveen
// ============================================================================

/// [idRemapped] is local only: an offline task got its server id. The event's
/// taskId is the old temporary id and its task carries the new one.
enum TaskSocketEventType { created, updated, deleted, idRemapped }
