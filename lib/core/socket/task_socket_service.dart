// ============================================================================
// File: task_socket_service.dart
// Created Date: 01-Oct-2026
// Title: TaskSocketService
// Description:
//   Singleton that keeps one WebSocket open while the user is logged in,
//   reconnects with exponential backoff, and exposes typed task events.
//
// Class:
//   TaskSocketService
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:task_flow/core/config/server_config.dart';
import 'package:task_flow/core/socket/task_socket_connection_status.dart';
import 'package:task_flow/core/socket/task_socket_event.dart';
import 'package:task_flow/core/socket/task_socket_event_type.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class TaskSocketService {
  TaskSocketService(UserDetails userDetails) : _userDetails = userDetails;

  static const int _maxBackoffSeconds = 30;
  static const int _maxBackoffExponent = 5;

  final UserDetails _userDetails;

  final StreamController<TaskSocketEvent> _eventController =
      StreamController<TaskSocketEvent>.broadcast();
  final StreamController<TaskSocketConnectionStatus> _statusController =
      StreamController<TaskSocketConnectionStatus>.broadcast();
  final StreamController<void> _reconnectedController =
      StreamController<void>.broadcast();

  // Mutable connection state (exception to the "final field" rule).
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _shouldRun = false;
  bool _hasConnectedBefore = false;
  int _attempt = 0;
  TaskSocketConnectionStatus _status = TaskSocketConnectionStatus.disconnected;

  /// Created, updated and deleted task events.
  Stream<TaskSocketEvent> get events => _eventController.stream;

  /// Connection state changes (for a "reconnecting" indicator).
  Stream<TaskSocketConnectionStatus> get statuses => _statusController.stream;

  /// Fires after a connection that was lost comes back. Events sent while
  /// offline were missed, so listeners should re-fetch their data.
  Stream<void> get reconnected => _reconnectedController.stream;

  TaskSocketConnectionStatus get status => _status;

  /// Safe to call many times; does nothing if already running.
  Future<void> connect() async {
    if (_shouldRun) return;
    _shouldRun = true;
    await _open();
  }

  /// Stops reconnecting and closes the socket (call on logout).
  void disconnect() {
    _shouldRun = false;
    _hasConnectedBefore = false;
    _attempt = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _setStatus(TaskSocketConnectionStatus.disconnected);
  }

  Future<void> _open() async {
    final String? token = _userDetails.accessToken;
    if (!_shouldRun || token == null || token.isEmpty) return;

    _setStatus(TaskSocketConnectionStatus.connecting);

    try {
      final WebSocketChannel channel = WebSocketChannel.connect(
        _buildUri(token),
      );
      _channel = channel;

      // Completes when the handshake succeeds, throws if it is rejected.
      await channel.ready;

      if (!_shouldRun || _channel != channel) {
        channel.sink.close();
        return;
      }

      _subscription = channel.stream.listen(
        _onMessage,
        onError: (Object _) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
      );

      _onConnected();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  Uri _buildUri(String token) {
    String base = ServerConfig.baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return Uri.parse('$base/ws?token=${Uri.encodeQueryComponent(token)}');
  }

  void _onConnected() {
    _attempt = 0;
    _setStatus(TaskSocketConnectionStatus.connected);
    if (_hasConnectedBefore) {
      _reconnectedController.add(null);
    }
    _hasConnectedBefore = true;
  }

  void _scheduleReconnect() {
    if (!_shouldRun) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _setStatus(TaskSocketConnectionStatus.disconnected);

    final int seconds = min(
      1 << min(_attempt, _maxBackoffExponent),
      _maxBackoffSeconds,
    );
    _attempt++;

    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _reconnectTimer = null;
      _open();
    });
  }

  void _onMessage(dynamic message) {
    if (kDebugMode) debugPrint('WS message: $message');

    try {
      final dynamic decoded = jsonDecode(message as String);
      if (decoded is! Map<String, dynamic>) return;

      final dynamic data = decoded['data'];

      switch (decoded['event']) {
        case 'task_created':
          _emitTask(TaskSocketEventType.created, data);
        case 'task_updated':
          _emitTask(TaskSocketEventType.updated, data);
        case 'task_deleted':
          _emitDeleted(data);
        default:
          break;
      }
    } catch (e) {
      debugPrint('WS parse error: $e');
    }
  }

  void _emitTask(TaskSocketEventType type, dynamic data) {
    if (data is! Map<String, dynamic>) return;
    final TaskEntity task = TaskModel.fromJson(data).toEntity();
    _eventController.add(TaskSocketEvent(type, task.id, task: task));
  }

  void _emitDeleted(dynamic data) {
    int? id;
    if (data is Map<String, dynamic>) {
      final dynamic raw = data['id'] ?? data['task_id'];
      id = raw is int ? raw : int.tryParse('$raw');
    } else if (data is int) {
      id = data;
    }
    if (id == null) return;
    _eventController.add(TaskSocketEvent(TaskSocketEventType.deleted, id));
  }

  void _setStatus(TaskSocketConnectionStatus status) {
    if (_status == status) return;
    _status = status;
    _statusController.add(status);
  }
}
