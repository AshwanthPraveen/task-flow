// ============================================================================
// File: tasks_bloc.dart
// Created Date: 29-Sep-2026
// Title: TasksBloc
// Description:
//   Bloc that loads tasks page by page (infinite scroll), supports
//   pull-to-refresh and keeps existing items when load-more or refresh fails.
//   Also applies real-time task events received over the WebSocket.
//
// Class:
//   TasksBloc
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_flow/core/socket/task_socket_event.dart';
import 'package:task_flow/core/socket/task_socket_event_type.dart';
import 'package:task_flow/core/socket/task_socket_service.dart';
import 'package:task_flow/core/sync/task_local_change_bus.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/tasks_home/domain/usecases/get_tasks_usecase.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_event.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({
    required this._getTasksUseCase,
    required TaskSocketService socketService,
    required TaskLocalChangeBus localChanges,
  }) : super(const TasksInitial()) {
    on<TasksFetched>(_onFetched);
    on<TasksLoadMoreRequested>(_onLoadMoreRequested);
    on<TasksRefreshed>(_onRefreshed);
    on<TasksTaskAdded>(_onTaskAdded);
    on<TasksTaskUpdated>(_onTaskUpdated);
    on<TasksTaskDeleted>(_onTaskDeleted);
    on<TasksTaskIdRemapped>(_onTaskIdRemapped);

    _socketSubscription = socketService.events.listen(_onSocketEvent);
    _localChangeSubscription = localChanges.events.listen(_onSocketEvent);

    // Events sent while the socket was down were missed: reload page 1.
    _reconnectedSubscription = socketService.reconnected.listen((_) {
      if (!isClosed) add(const TasksRefreshed());
    });
  }

  final GetTasksUseCase _getTasksUseCase;
  late final StreamSubscription<TaskSocketEvent> _socketSubscription;
  late final StreamSubscription<TaskSocketEvent> _localChangeSubscription;
  late final StreamSubscription<void> _reconnectedSubscription;

  void _onSocketEvent(TaskSocketEvent event) {
    if (isClosed) return;

    switch (event.type) {
      case TaskSocketEventType.created:
        final TaskEntity? created = event.task;
        if (created != null) add(TasksTaskAdded(created));
      case TaskSocketEventType.updated:
        final TaskEntity? updated = event.task;
        if (updated != null) add(TasksTaskUpdated(updated));
      case TaskSocketEventType.deleted:
        add(TasksTaskDeleted(event.taskId));
      case TaskSocketEventType.idRemapped:
        final TaskEntity? remapped = event.task;
        if (remapped != null) add(TasksTaskIdRemapped(event.taskId, remapped));
    }
  }

  void _onTaskAdded(TasksTaskAdded event, Emitter<TasksState> emit) {
    final TasksState current = state;
    final TaskEntity task = event.task;

    if (current is TasksLoaded) {
      // Already present (e.g. the same task arrived via WebSocket).
      if (current.tasks.any((t) => t.id == task.id)) return;

      emit(
        current.copyWith(
          tasks: [task, ...current.tasks],
          total: current.total + 1,
        ),
      );
    } else if (current is TasksEmpty) {
      // First task ever: leave the empty state.
      emit(TasksLoaded(tasks: [task], page: 1, total: 1, hasMore: false));
    }
  }

  void _onTaskUpdated(TasksTaskUpdated event, Emitter<TasksState> emit) {
    final TasksState current = state;
    if (current is! TasksLoaded) return;

    final int index = current.tasks.indexWhere((t) => t.id == event.task.id);
    if (index == -1) return;

    // Ignore stale events (an older version than the one already shown).
    if (event.task.version < current.tasks[index].version) return;

    final List<TaskEntity> tasks = [...current.tasks];
    tasks[index] = event.task;

    emit(current.copyWith(tasks: tasks));
  }

  void _onTaskIdRemapped(
    TasksTaskIdRemapped event,
    Emitter<TasksState> emit,
  ) {
    final TasksState current = state;
    if (current is! TasksLoaded) return;

    final int oldIndex = current.tasks.indexWhere((t) => t.id == event.oldId);
    if (oldIndex == -1) return;

    final List<TaskEntity> tasks = [...current.tasks];
    final int newIndex = tasks.indexWhere((t) => t.id == event.task.id);

    if (newIndex == -1) {
      tasks[oldIndex] = event.task;
    } else {
      // The real task already arrived (WebSocket echo): keep one copy.
      tasks[newIndex] = event.task;
      tasks.removeAt(oldIndex);
    }

    emit(current.copyWith(tasks: tasks));
  }

  void _onTaskDeleted(TasksTaskDeleted event, Emitter<TasksState> emit) {
    final TasksState current = state;
    if (current is! TasksLoaded) return;
    if (!current.tasks.any((t) => t.id == event.id)) return;

    final List<TaskEntity> tasks = current.tasks
        .where((t) => t.id != event.id)
        .toList();

    if (tasks.isEmpty) {
      // Nothing left on this page: show empty, or reload if more pages exist.
      if (current.hasMore) {
        add(const TasksRefreshed());
      } else {
        emit(const TasksEmpty());
      }
      return;
    }

    emit(
      current.copyWith(
        tasks: tasks,
        total: current.total > 0 ? current.total - 1 : 0,
      ),
    );
  }

  Future<void> _onFetched(TasksFetched event, Emitter<TasksState> emit) async {
    if (state is TasksLoading) return;

    emit(const TasksLoading());

    final result = await _getTasksUseCase(const GetTasksParams(page: 1));

    result.fold(
      (failure) => emit(TasksFailure(failure.message)),
      (list) => emit(
        list.items.isEmpty
            ? const TasksEmpty()
            : TasksLoaded(
                tasks: list.items,
                page: list.page,
                total: list.total,
                hasMore: list.hasMore,
              ),
      ),
    );
  }

  Future<void> _onLoadMoreRequested(
    TasksLoadMoreRequested event,
    Emitter<TasksState> emit,
  ) async {
    final TasksState current = state;

    // Scroll listener must not auto-loop after a failure; user taps retry.
    if (current is TasksLoaded && current.loadMoreFailed) return;
    await _loadNextPage(emit);
  }

  Future<void> _loadNextPage(Emitter<TasksState> emit) async {
    final TasksState current = state;

    if (current is! TasksLoaded ||
        current.isLoadingMore ||
        current.isRefreshing ||
        !current.hasMore) {
      return;
    }

    final int currentPage = current.page;

    emit(
      current.copyWith(
        isLoadingMore: true,
        refreshFailed: false,
        clearErrorMessage: true,
      ),
    );

    final result = await _getTasksUseCase(
      GetTasksParams(page: currentPage + 1),
    );

    // A refresh started or finished while this request was in flight; drop
    // stale page.
    final TasksState latest = state;
    if (latest is! TasksLoaded ||
        !latest.isLoadingMore ||
        latest.page != currentPage) {
      return;
    }

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isLoadingMore: false,
          loadMoreFailed: true,
          errorMessage: failure.message,
        ),
      ),
      (list) => emit(
        latest.copyWith(
          tasks: _mergeById(latest.tasks, list.items),
          page: list.page,
          total: list.total,
          hasMore: list.hasMore,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onRefreshed(
    TasksRefreshed event,
    Emitter<TasksState> emit,
  ) async {
    final TasksState current = state;

    if (current is TasksLoading) return;
    if (current is TasksLoaded && current.isRefreshing) return;

    if (current is TasksLoaded) {
      emit(
        current.copyWith(
          isRefreshing: true,
          isLoadingMore: false,
          loadMoreFailed: false,
          refreshFailed: false,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(const TasksLoading());
    }

    final result = await _getTasksUseCase(const GetTasksParams(page: 1));

    result.fold(
      (failure) => emit(
        // Full-screen error only if there is nothing to show.
        current is TasksLoaded && current.tasks.isNotEmpty
            ? current.copyWith(
                isRefreshing: false,
                isLoadingMore: false,
                loadMoreFailed: false,
                refreshFailed: true,
                errorMessage: failure.message,
              )
            : TasksFailure(failure.message),
      ),
      (list) => emit(
        list.items.isEmpty
            ? const TasksEmpty()
            : TasksLoaded(
                tasks: list.items,
                page: list.page,
                total: list.total,
                hasMore: list.hasMore,
              ),
      ),
    );
  }

  /// Appends only items whose id is not already present (server pages can
  /// shift while scrolling).
  List<TaskEntity> _mergeById(
    List<TaskEntity> existing,
    List<TaskEntity> incoming,
  ) {
    final Set<int> ids = existing.map((task) => task.id).toSet();
    return [...existing, ...incoming.where((task) => ids.add(task.id))];
  }

  @override
  Future<void> close() async {
    await _socketSubscription.cancel();
    await _localChangeSubscription.cancel();
    await _reconnectedSubscription.cancel();
    return super.close();
  }
}
