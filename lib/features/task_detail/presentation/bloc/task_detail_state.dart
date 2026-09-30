// ============================================================================
// File: task_detail_state.dart
// Created Date: 30-Sep-2026
// Title: TaskDetailState
// Description:
//   Single state for the task detail screen holding the loaded task, the
//   inline edit field and draft, validation and API errors, the running
//   action (save, status update, delete) and one-time feedback.
//
// Class:
//   TaskDetailStatus
//   TaskDetailField
//   TaskDetailAction
//   TaskDetailFeedback
//   TaskDetailState
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

/// Progress of loading the task itself.
enum TaskDetailStatus { initial, loading, loaded, failure }

/// Fields that can be edited inline.
enum TaskDetailField { title, description }

/// API call currently running (only one at a time).
enum TaskDetailAction { none, savingField, updatingStatus, deleting }

/// One-time result handled by the page's BlocListener (toast, pop).
enum TaskDetailFeedback { none, updated, deleted, failed }

class TaskDetailState extends Equatable {
  const TaskDetailState({
    this.status = TaskDetailStatus.initial,
    this.task,
    this.errorMessage,
    this.editingField,
    this.draft = '',
    this.draftError,
    this.action = TaskDetailAction.none,
    this.actionError,
    this.feedback = TaskDetailFeedback.none,
  });

  final TaskDetailStatus status;
  final TaskEntity? task;
  final String? errorMessage;
  final TaskDetailField? editingField;
  final String draft;
  final String? draftError;
  final TaskDetailAction action;
  final String? actionError;
  final TaskDetailFeedback feedback;

  bool get isLoading => status == TaskDetailStatus.loading;
  bool get isBusy => action != TaskDetailAction.none;
  bool get isEditing => editingField != null;
  bool get isSavingField => action == TaskDetailAction.savingField;
  bool get isUpdatingStatus => action == TaskDetailAction.updatingStatus;
  bool get isDeleting => action == TaskDetailAction.deleting;

  String get _currentFieldValue => switch (editingField) {
    TaskDetailField.title => task?.title ?? '',
    TaskDetailField.description => task?.description ?? '',
    null => '',
  };

  bool get isDraftChanged => draft.trim() != _currentFieldValue;

  /// Enables the save (tick) button.
  bool get canSaveDraft =>
      isEditing &&
      !isBusy &&
      draft.trim().isNotEmpty &&
      draftError == null &&
      isDraftChanged;

  TaskDetailState copyWith({
    TaskDetailStatus? status,
    TaskEntity? task,
    String? errorMessage,
    TaskDetailField? editingField,
    String? draft,
    String? draftError,
    TaskDetailAction? action,
    String? actionError,
    TaskDetailFeedback? feedback,
    bool clearErrorMessage = false,
    bool clearEditingField = false,
    bool clearDraftError = false,
    bool clearActionError = false,
  }) {
    return TaskDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      editingField: clearEditingField
          ? null
          : (editingField ?? this.editingField),
      draft: draft ?? this.draft,
      draftError: clearDraftError ? null : (draftError ?? this.draftError),
      action: action ?? this.action,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    task,
    errorMessage,
    editingField,
    draft,
    draftError,
    action,
    actionError,
    feedback,
  ];
}
