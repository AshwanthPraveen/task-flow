// ============================================================================
// File: create_task_event.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskEvent
// Description:
//   Events handled by CreateTaskBloc: title and description changes,
//   submit and status reset.
//
// Class:
//   CreateTaskEvent
//   CreateTaskTitleChanged
//   CreateTaskDescriptionChanged
//   CreateTaskSubmitted
//   CreateTaskStatusReset
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

abstract class CreateTaskEvent extends Equatable {
  const CreateTaskEvent();

  @override
  List<Object?> get props => [];
}

class CreateTaskTitleChanged extends CreateTaskEvent {
  const CreateTaskTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

class CreateTaskDescriptionChanged extends CreateTaskEvent {
  const CreateTaskDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

class CreateTaskSubmitted extends CreateTaskEvent {
  const CreateTaskSubmitted();
}

class CreateTaskStatusReset extends CreateTaskEvent {
  const CreateTaskStatusReset();
}
