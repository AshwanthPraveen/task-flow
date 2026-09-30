// ============================================================================
// File: create_task_state.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskState
// Description:
//   Single state for the create task dialog holding field values,
//   validation errors, request status, error message and the created task.
//
// Class:
//   CreateTaskStatus
//   CreateTaskState
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

enum CreateTaskStatus { initial, loading, success, failure }

class CreateTaskState extends Equatable {
  const CreateTaskState({
    this.title = '',
    this.description = '',
    this.titleError,
    this.descriptionError,
    this.status = CreateTaskStatus.initial,
    this.errorMessage,
    this.task,
  });

  final String title;
  final String description;
  final String? titleError;
  final String? descriptionError;
  final CreateTaskStatus status;
  final String? errorMessage;
  final TaskEntity? task;

  bool get isLoading => status == CreateTaskStatus.loading;

  bool get isFormValid =>
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      titleError == null &&
      descriptionError == null;

  CreateTaskState copyWith({
    String? title,
    String? description,
    String? titleError,
    String? descriptionError,
    CreateTaskStatus? status,
    String? errorMessage,
    TaskEntity? task,
    bool clearTitleError = false,
    bool clearDescriptionError = false,
    bool clearErrorMessage = false,
  }) {
    return CreateTaskState(
      title: title ?? this.title,
      description: description ?? this.description,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      descriptionError: clearDescriptionError
          ? null
          : (descriptionError ?? this.descriptionError),
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      task: task ?? this.task,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    titleError,
    descriptionError,
    status,
    errorMessage,
    task,
  ];
}
