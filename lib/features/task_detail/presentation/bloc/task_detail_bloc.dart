// ============================================================================
// File: task_detail_bloc.dart
// Created Date: 30-Sep-2026
// Title: TaskDetailBloc
// Description:
//   Handles task detail screen logic: loading the task by id, inline edit
//   of title and description (start, live validation, cancel, save), status
//   change, delete and feedback reset. Also applies real-time updates and
//   deletes of the open task received over the WebSocket.
//
// Class:
//   TaskDetailBloc
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/socket/task_socket_event.dart';
import 'package:task_flow/core/socket/task_socket_event_type.dart';
import 'package:task_flow/core/socket/task_socket_service.dart';
import 'package:task_flow/features/task_detail/domain/usecases/delete_task_usecase.dart';
import 'package:task_flow/features/task_detail/domain/usecases/get_task_detail_usecase.dart';
import 'package:task_flow/features/task_detail/domain/usecases/update_task_usecase.dart';
import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_event.dart';
import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_state.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  TaskDetailBloc({
    required this._getTaskDetailUseCase,
    required this._updateTaskUseCase,
    required this._deleteTaskUseCase,
    required TaskSocketService socketService,
  }) : super(const TaskDetailState()) {
    on<TaskDetailFetched>(_onFetched);
    on<TaskDetailEditStarted>(_onEditStarted);
    on<TaskDetailDraftChanged>(_onDraftChanged);
    on<TaskDetailEditCancelled>(_onEditCancelled);
    on<TaskDetailEditSaved>(_onEditSaved);
    on<TaskDetailStatusChanged>(_onStatusChanged);
    on<TaskDetailDeleteConfirmed>(_onDeleteConfirmed);
    on<TaskDetailFeedbackReset>(_onFeedbackReset);
    on<TaskDetailRemoteUpdated>(_onRemoteUpdated);
    on<TaskDetailRemoteDeleted>(_onRemoteDeleted);
    on<TaskDetailRefreshed>(_onRefreshed);

    _socketSubscription = socketService.events.listen(_onSocketEvent);

    // Events sent while the socket was down were missed: reload quietly.
    _reconnectedSubscription = socketService.reconnected.listen((_) {
      if (!isClosed) add(const TaskDetailRefreshed());
    });
  }

  final GetTaskDetailUseCase _getTaskDetailUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  late final StreamSubscription<TaskSocketEvent> _socketSubscription;
  late final StreamSubscription<void> _reconnectedSubscription;

  static const int _minTitleLength = 5;
  static const int _minDescriptionLength = 10;

  // Id of the task this screen shows (set by the first fetch).
  int? _taskId;

  // True once the task is gone (deleted here or elsewhere). Stops the same
  // delete from being handled twice (own delete + socket echo).
  bool _isDeleted = false;

  void _onSocketEvent(TaskSocketEvent event) {
    if (isClosed || event.taskId != _taskId) return;

    switch (event.type) {
      case TaskSocketEventType.updated:
        final TaskEntity? task = event.task;
        if (task != null) add(TaskDetailRemoteUpdated(task));
      case TaskSocketEventType.deleted:
        add(const TaskDetailRemoteDeleted());
      case TaskSocketEventType.created:
        break;
    }
  }

  String? _validateDraft(TaskDetailField field, String value) {
    final String text = value.trim();
    if (text.isEmpty) return null;

    switch (field) {
      case TaskDetailField.title:
        if (text.length < _minTitleLength) {
          return 'Title must be at least $_minTitleLength characters';
        }
      case TaskDetailField.description:
        if (text.length < _minDescriptionLength) {
          return 'Description must be at least $_minDescriptionLength characters';
        }
    }
    return null;
  }

  Future<void> _onFetched(
    TaskDetailFetched event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state.isLoading) return;

    _taskId = event.id;

    emit(
      state.copyWith(status: TaskDetailStatus.loading, clearErrorMessage: true),
    );

    final result = await _getTaskDetailUseCase(
      GetTaskDetailParams(id: event.id),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (task) =>
          emit(state.copyWith(status: TaskDetailStatus.loaded, task: task)),
    );
  }

  void _onEditStarted(
    TaskDetailEditStarted event,
    Emitter<TaskDetailState> emit,
  ) {
    final task = state.task;
    if (task == null || state.isBusy) return;

    // Starting a second field replaces the first one, which cancels it.
    final String initialDraft = event.field == TaskDetailField.title
        ? task.title
        : (task.description ?? '');

    emit(
      state.copyWith(
        editingField: event.field,
        draft: initialDraft,
        clearDraftError: true,
        clearActionError: true,
      ),
    );
  }

  void _onDraftChanged(
    TaskDetailDraftChanged event,
    Emitter<TaskDetailState> emit,
  ) {
    final TaskDetailField? field = state.editingField;
    if (field == null) return;

    final String? error = _validateDraft(field, event.value);
    emit(
      state.copyWith(
        draft: event.value,
        draftError: error,
        clearDraftError: error == null,
        clearActionError: true,
      ),
    );
  }

  void _onEditCancelled(
    TaskDetailEditCancelled event,
    Emitter<TaskDetailState> emit,
  ) {
    if (state.isSavingField) return;

    emit(
      state.copyWith(
        clearEditingField: true,
        draft: '',
        clearDraftError: true,
        clearActionError: true,
      ),
    );
  }

  Future<void> _onEditSaved(
    TaskDetailEditSaved event,
    Emitter<TaskDetailState> emit,
  ) async {
    final task = state.task;
    final TaskDetailField? field = state.editingField;
    if (task == null || field == null || !state.canSaveDraft) return;

    final String draft = state.draft.trim();

    emit(
      state.copyWith(
        action: TaskDetailAction.savingField,
        clearActionError: true,
      ),
    );

    final result = await _updateTaskUseCase(
      UpdateTaskParams(
        id: task.id,
        title: field == TaskDetailField.title ? draft : task.title,
        description: field == TaskDetailField.description
            ? draft
            : task.description,
        status: task.status,
        version: task.version,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          action: TaskDetailAction.none,
          actionError: failure.message,
          feedback: TaskDetailFeedback.failed,
        ),
      ),
      (updated) => emit(
        state.copyWith(
          task: updated,
          action: TaskDetailAction.none,
          clearEditingField: true,
          draft: '',
          clearDraftError: true,
          clearActionError: true,
          feedback: TaskDetailFeedback.updated,
        ),
      ),
    );
  }

  Future<void> _onStatusChanged(
    TaskDetailStatusChanged event,
    Emitter<TaskDetailState> emit,
  ) async {
    final task = state.task;
    if (task == null || state.isBusy || event.status == task.status) return;

    emit(
      state.copyWith(
        action: TaskDetailAction.updatingStatus,
        clearActionError: true,
      ),
    );

    final result = await _updateTaskUseCase(
      UpdateTaskParams(
        id: task.id,
        title: task.title,
        description: task.description,
        status: event.status,
        version: task.version,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          action: TaskDetailAction.none,
          actionError: failure.message,
          feedback: TaskDetailFeedback.failed,
        ),
      ),
      (updated) => emit(
        state.copyWith(
          task: updated,
          action: TaskDetailAction.none,
          feedback: TaskDetailFeedback.updated,
        ),
      ),
    );
  }

  Future<void> _onDeleteConfirmed(
    TaskDetailDeleteConfirmed event,
    Emitter<TaskDetailState> emit,
  ) async {
    final task = state.task;
    if (task == null || state.isBusy) return;

    emit(
      state.copyWith(action: TaskDetailAction.deleting, clearActionError: true),
    );

    final result = await _deleteTaskUseCase(DeleteTaskParams(id: task.id));

    result.fold(
      (failure) => emit(
        state.copyWith(
          action: TaskDetailAction.none,
          actionError: failure.message,
          feedback: TaskDetailFeedback.failed,
        ),
      ),
      (_) {
        _isDeleted = true;
        emit(
          state.copyWith(
            action: TaskDetailAction.none,
            feedback: TaskDetailFeedback.deleted,
          ),
        );
      },
    );
  }

  void _onFeedbackReset(
    TaskDetailFeedbackReset event,
    Emitter<TaskDetailState> emit,
  ) {
    emit(state.copyWith(feedback: TaskDetailFeedback.none));
  }

  void _onRemoteUpdated(
    TaskDetailRemoteUpdated event,
    Emitter<TaskDetailState> emit,
  ) {
    final task = state.task;

    // While our own save is in flight its response will replace the task.
    if (task == null || _isDeleted || state.isBusy) return;

    // Ignore stale events (an older version than the one already shown).
    if (event.task.version < task.version) return;

    // Only the task is replaced; editingField and draft stay untouched, so
    // an edit in progress is kept.
    emit(state.copyWith(task: event.task));
  }

  void _onRemoteDeleted(
    TaskDetailRemoteDeleted event,
    Emitter<TaskDetailState> emit,
  ) {
    // Our own delete is in flight, or the delete was already handled.
    if (_isDeleted || state.isDeleting) return;

    _isDeleted = true;

    // Reuses the existing "deleted" feedback: the page shows the toast and
    // pops back.
    emit(
      state.copyWith(
        clearEditingField: true,
        draft: '',
        clearDraftError: true,
        clearActionError: true,
        feedback: TaskDetailFeedback.deleted,
      ),
    );
  }

  Future<void> _onRefreshed(
    TaskDetailRefreshed event,
    Emitter<TaskDetailState> emit,
  ) async {
    final int? id = _taskId;
    if (id == null || state.task == null || state.isBusy || _isDeleted) return;

    final result = await _getTaskDetailUseCase(GetTaskDetailParams(id: id));

    result.fold((failure) {
      // 404 after a reconnect means it was deleted while we were offline.
      if (failure is ServerFailure && failure.statusCode == 404) {
        add(const TaskDetailRemoteDeleted());
      }
    }, (task) => add(TaskDetailRemoteUpdated(task)));
  }

  @override
  Future<void> close() async {
    await _socketSubscription.cancel();
    await _reconnectedSubscription.cancel();
    return super.close();
  }
}
