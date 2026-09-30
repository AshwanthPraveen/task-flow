// ============================================================================
// File: tasks_event.dart
// Created Date: 29-Sep-2026
// Title: TasksEvent
// Description:
//   Events handled by TasksBloc: first page fetch, load more (next page) and
//   pull-to-refresh (reset to page 1).
//
// Class:
//   TasksEvent
//   TasksFetched
//   TasksLoadMoreRequested
//   TasksRefreshed
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class TasksFetched extends TasksEvent {
  const TasksFetched();
}

class TasksLoadMoreRequested extends TasksEvent {
  const TasksLoadMoreRequested();
}

class TasksRefreshed extends TasksEvent {
  const TasksRefreshed();
}

class TasksTaskAdded extends TasksEvent {
  const TasksTaskAdded(this.task);

  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}

class TasksTaskUpdated extends TasksEvent {
  const TasksTaskUpdated(this.task);

  final TaskEntity task;

  @override
  List<Object?> get props => <Object?>[task];
}

class TasksTaskDeleted extends TasksEvent {
  const TasksTaskDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => <Object?>[id];
}
