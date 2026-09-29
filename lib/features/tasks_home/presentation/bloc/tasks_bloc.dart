// ============================================================================
// File: tasks_bloc.dart
// Created Date: 29-Sep-2026
// Title: TasksBloc
// Description:
//   Bloc that loads tasks page by page (infinite scroll), supports
//   pull-to-refresh and keeps existing items when load-more or refresh fails.
//
// Class:
//   TasksBloc
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/tasks_home/domain/usecases/get_tasks_usecase.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_event.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({required this._getTasksUseCase}) : super(const TasksInitial()) {
    on<TasksFetched>(_onFetched);
    on<TasksLoadMoreRequested>(_onLoadMoreRequested);
    on<TasksRefreshed>(_onRefreshed);
  }

  final GetTasksUseCase _getTasksUseCase;

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
}
