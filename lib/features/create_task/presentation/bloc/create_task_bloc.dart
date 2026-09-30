// ============================================================================
// File: create_task_bloc.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskBloc
// Description:
//   Handles create task dialog logic: live title and description
//   validation, task creation through CreateTaskUseCase and status reset.
//
// Class:
//   CreateTaskBloc
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/create_task/domain/usecases/create_task_usecase.dart';
import 'package:task_flow/features/create_task/presentation/bloc/create_task_event.dart';
import 'package:task_flow/features/create_task/presentation/bloc/create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  CreateTaskBloc({required this._createTaskUseCase})
    : super(const CreateTaskState()) {
    on<CreateTaskTitleChanged>(_onTitleChanged);
    on<CreateTaskDescriptionChanged>(_onDescriptionChanged);
    on<CreateTaskSubmitted>(_onSubmitted);
    on<CreateTaskStatusReset>(_onStatusReset);
  }

  final CreateTaskUseCase _createTaskUseCase;

  static const int _minTitleLength = 5;
  static const int _minDescriptionLength = 10;

  String? _validateTitle(String value) {
    final String title = value.trim();
    if (title.isEmpty) return null;
    if (title.length < _minTitleLength) {
      return 'Title must be at least $_minTitleLength characters';
    }
    return null;
  }

  String? _validateDescription(String value) {
    final String description = value.trim();
    if (description.isEmpty) return null;
    if (description.length < _minDescriptionLength) {
      return 'Description must be at least $_minDescriptionLength characters';
    }
    return null;
  }

  void _onTitleChanged(
    CreateTaskTitleChanged event,
    Emitter<CreateTaskState> emit,
  ) {
    final String? error = _validateTitle(event.title);
    emit(
      state.copyWith(
        title: event.title,
        titleError: error,
        clearTitleError: error == null,
      ),
    );
  }

  void _onDescriptionChanged(
    CreateTaskDescriptionChanged event,
    Emitter<CreateTaskState> emit,
  ) {
    final String? error = _validateDescription(event.description);
    emit(
      state.copyWith(
        description: event.description,
        descriptionError: error,
        clearDescriptionError: error == null,
      ),
    );
  }

  Future<void> _onSubmitted(
    CreateTaskSubmitted event,
    Emitter<CreateTaskState> emit,
  ) async {
    if (!state.isFormValid || state.isLoading) return;

    emit(
      state.copyWith(status: CreateTaskStatus.loading, clearErrorMessage: true),
    );

    final result = await _createTaskUseCase(
      CreateTaskParams(
        title: state.title.trim(),
        description: state.description.trim(),
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CreateTaskStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (task) =>
          emit(state.copyWith(status: CreateTaskStatus.success, task: task)),
    );
  }

  void _onStatusReset(
    CreateTaskStatusReset event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(
      state.copyWith(status: CreateTaskStatus.initial, clearErrorMessage: true),
    );
  }
}
