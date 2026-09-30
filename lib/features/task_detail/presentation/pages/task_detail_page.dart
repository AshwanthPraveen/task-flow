// ============================================================================
// File: task_detail_page.dart
// Created Date: 30-Sep-2026
// Title: TaskDetailPage
// Description:
//
//   Provides the responsive task detail screen for TaskFlow.
//
//   Handles:
//   - Loading (shimmer), error (with retry) and loaded states through
//     TaskDetailBloc
//   - Jira style inline edit of title and description (tick / cross)
//   - Status dropdown that saves immediately
//   - Delete button inside the screen with a confirmation pop up
//   - Details card and activity built from the task timestamps
//   - One column layout on mobile, two columns on tablet and desktop
//
// Class:
//   TaskDetailPage
//   _TaskDetailView
//   _InlineEditField
//   _InlineEditor
//   _TaskDetailsCard
//   _DetailRow
//   _StatusDropdown
//   _ActivitySection
//   _ActivityItem
//   _TaskDetailShimmer
//   _MessageView
//   _DeleteTaskDialog
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_flow/core/constants/app_strings.dart';
import 'package:task_flow/core/di/injection.dart';
import 'package:task_flow/core/responsive/responsive.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/theme/app_spacing.dart';
import 'package:task_flow/core/theme/app_text_styles.dart';
import 'package:task_flow/core/widgets/app_bar.dart';
import 'package:task_flow/core/widgets/app_button.dart';
import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_bloc.dart';
import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_event.dart';
import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_state.dart';
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

const double _maxContentWidth = 1000;
const double _sidePanelWidth = 300;

const Map<String, String> _statusLabels = {
  'todo': AppStrings.statusTodo,
  'in_progress': AppStrings.statusInProgress,
  'completed': AppStrings.statusCompleted,
};

const List<String> _months = [
  AppStrings.january,
  AppStrings.february,
  AppStrings.march,
  AppStrings.april,
  AppStrings.may,
  AppStrings.june,
  AppStrings.july,
  AppStrings.august,
  AppStrings.september,
  AppStrings.october,
  AppStrings.november,
  AppStrings.december,
];

Color _statusColor(String status) {
  switch (status) {
    case 'in_progress':
      return AppColors.primary;
    case 'completed':
      return Colors.green.shade400;
    default:
      return AppColors.textMuted;
  }
}

String _formatDateTime(DateTime value) {
  final DateTime d = value.toLocal();
  final int hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final String minute = d.minute.toString().padLeft(2, '0');
  final String period = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${_months[d.month - 1]} ${d.year}, $hour:$minute $period';
}

String _timeAgo(DateTime value) {
  final Duration diff = DateTime.now().difference(value);
  if (diff.inSeconds < 60) return AppStrings.justNow;
  if (diff.inMinutes < 60) return '${diff.inMinutes} ${AppStrings.minutesAgo}';
  if (diff.inHours < 24) return '${diff.inHours} ${AppStrings.hoursAgo}';
  if (diff.inDays < 30) return '${diff.inDays} ${AppStrings.daysAgo}';
  return _formatDateTime(value);
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.md),
    border: Border.all(color: AppColors.border),
  );
}

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({required this.taskId, super.key});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskDetailBloc>(
      create: (_) => getIt<TaskDetailBloc>()..add(TaskDetailFetched(taskId)),
      child: _TaskDetailView(taskId: taskId),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskDetailBloc, TaskDetailState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback &&
          current.feedback != TaskDetailFeedback.none,
      listener: _onFeedback,
      child: BlocBuilder<TaskDetailBloc, TaskDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context),
            body: AbsorbPointer(
              absorbing: state.isDeleting,
              child: _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  void _onFeedback(BuildContext context, TaskDetailState state) {
    final TaskDetailFeedback feedback = state.feedback;

    switch (feedback) {
      case TaskDetailFeedback.updated:
        MotionToast.success(
          title: const Text(AppStrings.taskUpdated),
          description: const Text(AppStrings.taskUpdatedMessage),
        ).show(context);
      case TaskDetailFeedback.deleted:
        MotionToast.success(
          title: const Text(AppStrings.taskDeleted),
          description: const Text(AppStrings.taskDeletedMessage),
        ).show(context);
      case TaskDetailFeedback.failed:
        MotionToast.error(
          title: const Text(AppStrings.updateFailed),
          description: Text(state.actionError ?? AppStrings.somethingWentWrong),
        ).show(context);
      case TaskDetailFeedback.none:
        break;
    }

    context.read<TaskDetailBloc>().add(const TaskDetailFeedbackReset());

    if (feedback == TaskDetailFeedback.deleted) {
      context.pop();
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return TaskFlowAppBar(
      title: AppStrings.taskDetail,
      showBackButton: true,
      onBackPressed: () => context.pop(),
    );
  }

  Widget _buildDeleteButton(BuildContext context, TaskDetailState state) {
    return AppButton(
      label: AppStrings.deleteTask,
      type: AppButtonType.outlined,
      icon: Icons.delete_outline_rounded,
      isFullWidth: true,
      isLoading: state.isDeleting,
      isDisabled: state.isBusy,
      onPressed: () => _confirmDelete(context),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteTaskDialog(),
    );

    if (confirmed == true && context.mounted) {
      context.read<TaskDetailBloc>().add(const TaskDetailDeleteConfirmed());
    }
  }

  Widget _buildBody(BuildContext context, TaskDetailState state) {
    switch (state.status) {
      case TaskDetailStatus.initial:
      case TaskDetailStatus.loading:
        return const _TaskDetailShimmer();
      case TaskDetailStatus.failure:
        return _MessageView(
          icon: Icons.error_outline_rounded,
          title: AppStrings.somethingWentWrong,
          message: state.errorMessage ?? AppStrings.somethingWentWrong,
          actionLabel: AppStrings.tryAgain,
          onAction: () =>
              context.read<TaskDetailBloc>().add(TaskDetailFetched(taskId)),
        );
      case TaskDetailStatus.loaded:
        final TaskEntity? task = state.task;
        if (task == null) return const _TaskDetailShimmer();
        return _buildLoaded(context, state, task);
    }
  }

  Widget _buildLoaded(
    BuildContext context,
    TaskDetailState state,
    TaskEntity task,
  ) {
    final bool isMobile = Responsive.device(context) == ResponsiveDevice.mobile;

    final Widget title = _InlineEditField(
      field: TaskDetailField.title,
      value: task.title,
      placeholder: AppStrings.taskTitle,
      textStyle: AppTextStyles.heading1.copyWith(fontSize: isMobile ? 24 : 28),
      maxLength: 50,
      minLines: 1,
      maxLines: 1,
    );

    final Widget description = _buildDescriptionCard(task);
    final Widget details = _TaskDetailsCard(
      task: task,
      isBusy: state.isBusy,
      isUpdatingStatus: state.isUpdatingStatus,
    );
    final Widget activity = _ActivitySection(task: task);
    final Widget deleteButton = _buildDeleteButton(context, state);
    final Widget key = Text(
      '${AppStrings.taskKeyPrefix}${task.id}',
      style: AppTextStyles.caption,
    );

    final Widget content = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              key,
              const SizedBox(height: AppSpacing.xs),
              title,
              const SizedBox(height: AppSpacing.md),
              details,
              const SizedBox(height: AppSpacing.md),
              description,
              const SizedBox(height: AppSpacing.md),
              activity,
              const SizedBox(height: AppSpacing.lg),
              deleteButton,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    key,
                    const SizedBox(height: AppSpacing.xs),
                    title,
                    const SizedBox(height: AppSpacing.lg),
                    description,
                    const SizedBox(height: AppSpacing.lg),
                    activity,
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: _sidePanelWidth,
                child: Column(
                  children: [
                    details,
                    const SizedBox(height: AppSpacing.md),
                    deleteButton,
                  ],
                ),
              ),
            ],
          );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: content,
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(TaskEntity task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.taskDescription, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: _InlineEditField(
              field: TaskDetailField.description,
              value: task.description ?? '',
              placeholder: AppStrings.addDescription,
              textStyle: AppTextStyles.bodyLarge,
              maxLength: 200,
              minLines: 4,
              maxLines: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows text; tapping it switches to [_InlineEditor] for the same field.
class _InlineEditField extends StatelessWidget {
  const _InlineEditField({
    required this.field,
    required this.value,
    required this.placeholder,
    required this.textStyle,
    required this.maxLength,
    required this.minLines,
    required this.maxLines,
  });

  final TaskDetailField field;
  final String value;
  final String placeholder;
  final TextStyle textStyle;
  final int maxLength;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailBloc, TaskDetailState>(
      builder: (context, state) {
        if (state.editingField == field) {
          return _InlineEditor(
            key: ValueKey(field),
            initialText: state.draft,
            textStyle: textStyle,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
          );
        }

        final bool isEmpty = value.trim().isEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          onTap: state.isBusy
              ? null
              : () => context.read<TaskDetailBloc>().add(
                  TaskDetailEditStarted(field),
                ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    isEmpty ? placeholder : value,
                    style: isEmpty
                        ? textStyle.copyWith(color: AppColors.textMuted)
                        : textStyle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Text field with tick and cross buttons. Created only while editing, so
/// its controller starts from the draft the bloc prepared.
class _InlineEditor extends StatefulWidget {
  const _InlineEditor({
    required this.initialText,
    required this.textStyle,
    required this.maxLength,
    required this.minLines,
    required this.maxLines,
    super.key,
  });

  final String initialText;
  final TextStyle textStyle;
  final int maxLength;
  final int minLines;
  final int maxLines;

  @override
  State<_InlineEditor> createState() => _InlineEditorState();
}

class _InlineEditorState extends State<_InlineEditor> {
  late final TextEditingController _controller;

  bool get _isSingleLine => widget.maxLines == 1;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialText)
      ..selection = TextSelection.collapsed(offset: widget.initialText.length);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailBloc, TaskDetailState>(
      builder: (context, state) {
        final TaskDetailBloc bloc = context.read<TaskDetailBloc>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  if (!state.isSavingField) {
                    bloc.add(const TaskDetailEditCancelled());
                  }
                },
              },
              child: TextField(
                controller: _controller,
                autofocus: true,
                enabled: !state.isSavingField,
                style: widget.textStyle,
                maxLength: widget.maxLength,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                textInputAction: _isSingleLine
                    ? TextInputAction.done
                    : TextInputAction.newline,
                onChanged: (value) => bloc.add(TaskDetailDraftChanged(value)),
                onSubmitted: _isSingleLine
                    ? (_) {
                        if (state.canSaveDraft) {
                          bloc.add(const TaskDetailEditSaved());
                        }
                      }
                    : null,
                decoration: InputDecoration(
                  isDense: true,
                  errorText: state.draftError ?? state.actionError,
                  counterStyle: AppTextStyles.caption,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  enabledBorder: _border(AppColors.border),
                  disabledBorder: _border(AppColors.border),
                  focusedBorder: _border(AppColors.primary),
                  errorBorder: _border(AppColors.error),
                  focusedErrorBorder: _border(AppColors.error),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: AppStrings.cancel,
                  onPressed: state.isSavingField
                      ? null
                      : () => bloc.add(const TaskDetailEditCancelled()),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
                if (state.isSavingField)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    tooltip: AppStrings.save,
                    onPressed: state.canSaveDraft
                        ? () => bloc.add(const TaskDetailEditSaved())
                        : null,
                    icon: Icon(
                      Icons.check_rounded,
                      color: state.canSaveDraft
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TaskDetailsCard extends StatelessWidget {
  const _TaskDetailsCard({
    required this.task,
    required this.isBusy,
    required this.isUpdatingStatus,
  });

  final TaskEntity task;
  final bool isBusy;
  final bool isUpdatingStatus;

  String _createdByLabel() {
    final int? currentUserId = getIt<UserDetails>().userId;

    return task.createdBy == currentUserId
        ? AppStrings.you
        : '${AppStrings.userPrefix}${task.createdBy}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.details, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            label: AppStrings.status,
            child: _StatusDropdown(
              status: task.status,
              isBusy: isBusy,
              isUpdating: isUpdatingStatus,
            ),
          ),
          _DetailRow(
            label: AppStrings.createdBy,
            child: Text(_createdByLabel(), style: AppTextStyles.bodySmall),
          ),
          _DetailRow(
            label: AppStrings.created,
            child: Text(
              _formatDateTime(task.createdAt),
              style: AppTextStyles.bodySmall,
            ),
          ),
          _DetailRow(
            label: AppStrings.lastUpdated,
            child: Text(
              _timeAgo(task.updatedAt),
              style: AppTextStyles.bodySmall,
            ),
          ),
          _DetailRow(
            label: AppStrings.task,
            child: Text(
              '${AppStrings.taskKeyPrefix}${task.id}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.status,
    required this.isBusy,
    required this.isUpdating,
  });

  final String status;
  final bool isBusy;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    // Keep unknown backend values selectable so the dropdown never asserts.
    final List<String> values = [
      ..._statusLabels.keys,
      if (!_statusLabels.containsKey(status)) status,
    ];

    return Row(
      children: [
        Flexible(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: status,
              isDense: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
              onChanged: isBusy
                  ? null
                  : (String? value) {
                      if (value != null && value != status) {
                        context.read<TaskDetailBloc>().add(
                          TaskDetailStatusChanged(value),
                        );
                      }
                    },
              items: values.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor(value),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _statusLabels[value] ?? value,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (isUpdating) ...[
          const SizedBox(width: AppSpacing.sm),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.activity, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          _ActivityItem(
            title: AppStrings.created,
            subtitle: _formatDateTime(task.createdAt),
          ),
          _ActivityItem(
            title: AppStrings.lastUpdated,
            subtitle: _formatDateTime(task.updatedAt),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer blocks with the same layout while the task loads.
class _TaskDetailShimmer extends StatelessWidget {
  const _TaskDetailShimmer();

  Widget _block({required double height, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.device(context) == ResponsiveDevice.mobile;

    final Widget content = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _block(height: 14, width: 60),
              const SizedBox(height: AppSpacing.xs),
              _block(height: 36),
              const SizedBox(height: AppSpacing.md),
              _block(height: 170),
              const SizedBox(height: AppSpacing.md),
              _block(height: 170),
              const SizedBox(height: AppSpacing.md),
              _block(height: 130),
              const SizedBox(height: AppSpacing.lg),
              _block(height: 44),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(height: 14, width: 60),
                    const SizedBox(height: AppSpacing.xs),
                    _block(height: 36),
                    const SizedBox(height: AppSpacing.lg),
                    _block(height: 170),
                    const SizedBox(height: AppSpacing.lg),
                    _block(height: 130),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: _sidePanelWidth,
                child: Column(
                  children: [
                    _block(height: 200),
                    const SizedBox(height: AppSpacing.md),
                    _block(height: 44),
                  ],
                ),
              ),
            ],
          );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: AppColors.surfaceElevated,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Big centered icon + title + message + action (error state).
class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 96, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

/// Confirmation pop up. Pops `true` when the user confirms the delete.
class _DeleteTaskDialog extends StatelessWidget {
  const _DeleteTaskDialog();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double dialogWidth = screenWidth < 600
        ? screenWidth - (AppSpacing.lg * 2)
        : 420;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(AppSpacing.xl),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.deleteTask, style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            Text(AppStrings.deleteTaskMessage, style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: AppStrings.cancel,
                  type: AppButtonType.outlined,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: AppStrings.delete,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
