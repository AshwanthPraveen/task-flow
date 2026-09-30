// ============================================================================
// File: task_detail_event.dart
// Created Date: 30-Sep-2026
// Title: TaskDetailEvent
// Description:
//   Events handled by TaskDetailBloc: load the task, inline edit of title
//   and description (start, type, cancel, save), status change, delete
//   confirmation and feedback reset.
//
// Class:
//   TaskDetailEvent
//   TaskDetailFetched
//   TaskDetailEditStarted
//   TaskDetailDraftChanged
//   TaskDetailEditCancelled
//   TaskDetailEditSaved
//   TaskDetailStatusChanged
//   TaskDetailDeleteConfirmed
//   TaskDetailFeedbackReset
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_state.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or retries loading) the task.
class TaskDetailFetched extends TaskDetailEvent {
  const TaskDetailFetched(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

/// User tapped the title or description to edit it.
class TaskDetailEditStarted extends TaskDetailEvent {
  const TaskDetailEditStarted(this.field);

  final TaskDetailField field;

  @override
  List<Object?> get props => [field];
}

/// User typed in the inline text field.
class TaskDetailDraftChanged extends TaskDetailEvent {
  const TaskDetailDraftChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// User pressed the cancel (wrong) button: restore the old text.
class TaskDetailEditCancelled extends TaskDetailEvent {
  const TaskDetailEditCancelled();
}

/// User pressed the save (tick) button: call the update API with the draft.
class TaskDetailEditSaved extends TaskDetailEvent {
  const TaskDetailEditSaved();
}

/// User picked a new status in the dropdown (saved immediately).
class TaskDetailStatusChanged extends TaskDetailEvent {
  const TaskDetailStatusChanged(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

/// User confirmed the delete pop-up.
class TaskDetailDeleteConfirmed extends TaskDetailEvent {
  const TaskDetailDeleteConfirmed();
}

/// Clears the one-time feedback after the page has handled it.
class TaskDetailFeedbackReset extends TaskDetailEvent {
  const TaskDetailFeedbackReset();
}

class TaskDetailRemoteUpdated extends TaskDetailEvent {
  const TaskDetailRemoteUpdated(this.task);

  final TaskEntity task;

  @override
  List<Object?> get props => <Object?>[task];
}

/// The task shown here was created offline and now has its real id.
class TaskDetailIdRemapped extends TaskDetailEvent {
  const TaskDetailIdRemapped(this.task);

  final TaskEntity task;

  @override
  List<Object?> get props => <Object?>[task];
}

class TaskDetailRemoteDeleted extends TaskDetailEvent {
  const TaskDetailRemoteDeleted();

  @override
  List<Object?> get props => <Object?>[];
}

class TaskDetailRefreshed extends TaskDetailEvent {
  const TaskDetailRefreshed();

  @override
  List<Object?> get props => <Object?>[];
}
