// ============================================================================
// File: tasks_state.dart
// Created Date: 29-Sep-2026
// Title: TasksState
// Description:
//   Sealed state hierarchy for TasksBloc. Every state that carries the list
//   extends TasksLoaded so items stay visible during load-more and refresh.
//
// Class:
//   TasksState
//   TasksInitial
//   TasksLoading
//   TasksEmpty
//   TasksFailure
//   TasksLoaded
//   TasksSuccess
//   TasksLoadingMore
//   TasksRefreshing
//   TasksLoadMoreFailure
//   TasksRefreshFailure
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

/// First page loading (full-screen loader).
class TasksLoading extends TasksState {
  const TasksLoading();
}

/// First page loaded successfully but there are no tasks.
class TasksEmpty extends TasksState {
  const TasksEmpty();
}

/// Full-screen error, only when there is nothing to show.
class TasksFailure extends TasksState {
  const TasksFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Single state that holds the loaded list. Flags describe what is happening
/// on top of it (load-more, refresh, and their failures).
class TasksLoaded extends TasksState {
  const TasksLoaded({
    required this.tasks,
    required this.page,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.loadMoreFailed = false,
    this.refreshFailed = false,
    this.errorMessage,
  });

  final List<TaskEntity> tasks;
  final int page;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool loadMoreFailed;
  final bool refreshFailed;
  final String? errorMessage;

  TasksLoaded copyWith({
    List<TaskEntity>? tasks,
    int? page,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? loadMoreFailed,
    bool? refreshFailed,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      refreshFailed: refreshFailed ?? this.refreshFailed,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    page,
    total,
    hasMore,
    isLoadingMore,
    isRefreshing,
    loadMoreFailed,
    refreshFailed,
    errorMessage,
  ];
}
