// ============================================================================
// File: connection_banner.dart
// Created Date: 01-Oct-2026
// Title: ConnectionBanner
// Description:
//   Slim status bar that shows the offline state, the sync progress and the
//   WebSocket connection state. Hidden when everything is fine. Priority:
//   offline, then sync, then live updates.
//
// Class:
//   ConnectionBanner
//   _ConnectionBannerState
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:task_flow/core/constants/app_strings.dart';
import 'package:task_flow/core/di/injection.dart';
import 'package:task_flow/core/network/connectivity_service.dart';
import 'package:task_flow/core/socket/task_socket_connection_status.dart';
import 'package:task_flow/core/socket/task_socket_service.dart';
import 'package:task_flow/core/sync/task_sync_service.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/theme/app_spacing.dart';

class ConnectionBanner extends StatefulWidget {
  const ConnectionBanner({super.key});

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  late final ConnectivityService _connectivity;
  late final TaskSocketService _socket;
  late final TaskSyncService _sync;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  bool _isOnline = true;
  late TaskSocketConnectionStatus _socketStatus;
  late TaskSyncStatus _syncStatus;

  @override
  void initState() {
    super.initState();

    _connectivity = getIt<ConnectivityService>();
    _socket = getIt<TaskSocketService>();
    _sync = getIt<TaskSyncService>();

    _socketStatus = _socket.status;
    _syncStatus = _sync.status;

    _connectivity.isOnline.then((bool online) {
      if (mounted) setState(() => _isOnline = online);
    });

    _subscriptions.addAll(<StreamSubscription<dynamic>>[
      _connectivity.onChanged.listen((bool online) {
        if (mounted) setState(() => _isOnline = online);
      }),
      _socket.statuses.listen((TaskSocketConnectionStatus status) {
        if (mounted) setState(() => _socketStatus = status);
      }),
      _sync.statuses.listen((TaskSyncStatus status) {
        if (mounted) setState(() => _syncStatus = status);
      }),
    ]);
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  ({IconData icon, String text, Color color})? _content() {
    if (!_isOnline) {
      return (
        icon: Icons.wifi_off_rounded,
        text: AppStrings.offlineBanner,
        color: AppColors.warning,
      );
    }

    switch (_syncStatus) {
      case TaskSyncStatus.syncing:
        return (
          icon: Icons.sync_rounded,
          text: AppStrings.syncingBanner,
          color: AppColors.accent,
        );
      case TaskSyncStatus.waitingToRetry:
        return (
          icon: Icons.sync_problem_rounded,
          text: AppStrings.syncRetryBanner,
          color: AppColors.warning,
        );
      case TaskSyncStatus.idle:
        break;
    }

    switch (_socketStatus) {
      case TaskSocketConnectionStatus.connecting:
        return (
          icon: Icons.podcasts_rounded,
          text: AppStrings.liveReconnecting,
          color: AppColors.accent,
        );
      case TaskSocketConnectionStatus.disconnected:
        return (
          icon: Icons.portable_wifi_off_rounded,
          text: AppStrings.liveDisconnected,
          color: AppColors.warning,
        );
      case TaskSocketConnectionStatus.connected:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ({IconData icon, String text, Color color})? content = _content();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: content == null
          ? const SizedBox(width: double.infinity)
          : SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: content.color.withValues(alpha: 0.12),
                  border: Border(top: BorderSide(color: content.color)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(content.icon, size: 16, color: content.color),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        content.text,
                        style: TextStyle(color: content.color, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
