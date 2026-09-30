// ============================================================================
// File: create_task_dialog.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskDialog
// Description:
//
//   Provides the dialog interface for creating a new task.
//
//   Handles:
//   - Task title input
//   - Task description input
//   - Field-level validation error display
//   - Create button disabled until the form is valid
//   - Loading state and API error display through CreateTaskBloc
//   - Dialog close action and closing on successful creation
//
//   Requires a CreateTaskBloc to be provided above this dialog.
//
// Class:
//
//   CreateTaskDialog
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:task_flow/core/constants/app_strings.dart';
import 'package:task_flow/core/responsive/responsive.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/theme/app_spacing.dart';
import 'package:task_flow/core/theme/app_text_styles.dart';
import 'package:task_flow/core/widgets/app_button.dart';
import 'package:task_flow/core/widgets/app_icon_button.dart';
import 'package:task_flow/core/widgets/app_text_field.dart';
import 'package:task_flow/features/create_task/presentation/bloc/create_task_bloc.dart';
import 'package:task_flow/features/create_task/presentation/bloc/create_task_event.dart';
import 'package:task_flow/features/create_task/presentation/bloc/create_task_state.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_bloc.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_event.dart';

class CreateTaskDialog extends StatefulWidget {
  const CreateTaskDialog({super.key});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  static const double _errorSlotHeight = 24;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double dialogWidth = screenWidth < 600
        ? screenWidth - (AppSpacing.lg * 2)
        : 480;
    final EdgeInsets dialogPadding = switch (Responsive.device(context)) {
      ResponsiveDevice.mobile => const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      ResponsiveDevice.tablet => const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      ResponsiveDevice.desktop => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      ResponsiveDevice.ultraHd => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
    };
    return BlocListener<CreateTaskBloc, CreateTaskState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: dialogPadding,
        child: Container(
          width: dialogWidth,
          padding: dialogPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: AppSpacing.xl,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: BlocBuilder<CreateTaskBloc, CreateTaskState>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(state),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTitleField(context, state),
                    const SizedBox(height: AppSpacing.xs),
                    _buildDescriptionField(context, state),
                    const SizedBox(height: AppSpacing.md),
                    _buildCreateButton(context, state),
                    _buildApiError(state.errorMessage),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onStatusChanged(BuildContext context, CreateTaskState state) {
    final TaskEntity? task = state.task;

    // Only add to tasks list if creation was successful and we have a task
    if (state.status == CreateTaskStatus.success && task != null) {
      context.read<TasksBloc>().add(TasksTaskAdded(task));

      MotionToast.success(
        title: const Text(AppStrings.taskCreated),
        description: const Text(AppStrings.taskCreatedMessage),
      ).show(context);

      Navigator.of(context).pop(task);
    }
  }

  Widget _buildHeader(CreateTaskState state) {
    return Row(
      children: [
        Expanded(
          child: Text(AppStrings.createTask, style: AppTextStyles.heading3),
        ),
        AppIconButton(
          onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
          icon: Icons.close_rounded,
          tooltip: AppStrings.close,
        ),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context, CreateTaskState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.taskTitle, style: AppTextStyles.bodyLarge),
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          controller: _titleController,
          maxLength: 50,
          maxLines: 1,
          enabled: !state.isLoading,
          onChanged: (value) =>
              context.read<CreateTaskBloc>().add(CreateTaskTitleChanged(value)),
        ),
        _buildErrorText(state.titleError),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, CreateTaskState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.taskDescription, style: AppTextStyles.bodyLarge),
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 200,
          enabled: !state.isLoading,
          onChanged: (value) => context.read<CreateTaskBloc>().add(
            CreateTaskDescriptionChanged(value),
          ),
        ),
        _buildErrorText(state.descriptionError),
      ],
    );
  }

  Widget _buildErrorText(String? error) {
    return SizedBox(
      height: _errorSlotHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.xxs,
          left: AppSpacing.xs,
        ),
        child: error == null
            ? null
            : Text(
                error,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context, CreateTaskState state) {
    return AppButton(
      label: AppStrings.create,
      isFullWidth: true,
      isDisabled: !state.isFormValid,
      isLoading: state.isLoading,
      onPressed: state.isFormValid
          ? () =>
                context.read<CreateTaskBloc>().add(const CreateTaskSubmitted())
          : null,
    );
  }

  Widget _buildApiError(String? message) {
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
    );
  }
}
