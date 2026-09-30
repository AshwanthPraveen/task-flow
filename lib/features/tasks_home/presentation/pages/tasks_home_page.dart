// ============================================================================
// File: tasks_home_page.dart
// Created Date: 29-Sep-2026
// Title: TasksHomePage
// Description:
//   Tasks home screen. Fetches the first page in initState, shows tasks in a
//   masonry grid with infinite scroll, pull-to-refresh, a text loader, and
//   big centered icons for the empty and error states.
//
// Class:
//   TasksHomePage
//   _TasksHomePageState
//   _LoadingView
//   _MessageView
//   _ListFooter
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:task_flow/core/di/injection.dart';
import 'package:task_flow/core/router/app_router.dart';
import 'package:task_flow/core/socket/task_socket_service.dart';
import 'package:task_flow/core/sync/task_sync_service.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/constants/app_strings.dart';
import 'package:task_flow/core/widgets/app_bar.dart';
import 'package:task_flow/core/widgets/connection_banner.dart';
import 'package:task_flow/features/create_task/presentation/pages/create_task_dialog.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_bloc.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_event.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_state.dart';
import 'package:task_flow/features/tasks_home/presentation/create_task_card.dart';
import 'package:task_flow/features/tasks_home/presentation/task_card.dart';
import 'package:go_router/go_router.dart';

class TasksHomePage extends StatefulWidget {
  const TasksHomePage({super.key});

  @override
  State<TasksHomePage> createState() => _TasksHomePageState();
}

class _TasksHomePageState extends State<TasksHomePage> {
  static const double _loadMoreThreshold = 300;

  final ScrollController _scrollController = ScrollController();
  late final TasksBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = context.read<TasksBloc>();

    getIt<TaskSocketService>().connect();
    getIt<TaskSyncService>().start();

    _bloc.add(const TasksFetched());

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final ScrollPosition position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _bloc.add(const TasksLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    _bloc.add(const TasksRefreshed());

    await _bloc.stream
        .firstWhere((s) => s is! TasksLoaded || !s.isRefreshing)
        .timeout(const Duration(seconds: 30), onTimeout: () => _bloc.state);
  }

  void _openTask(int taskId) {
    context.push(AppRouter.taskDetailPath(taskId));
  }

  int _columnCount(double width) {
    if (width >= 1000) return 4;
    if (width >= 700) return 3;
    if (width >= 550) return 2;

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TaskFlowAppBar(title: AppStrings.tasksHome),
      bottomNavigationBar: const ConnectionBanner(),
      body: BlocConsumer<TasksBloc, TasksState>(
        listenWhen: (previous, current) =>
            current is TasksLoaded &&
            current.refreshFailed &&
            !(previous is TasksLoaded && previous.refreshFailed),
        listener: (context, state) {
          if (state is TasksLoaded) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? AppStrings.refreshFailed),
                ),
              );
          }
        },
        builder: (context, state) {
          return switch (state) {
            TasksInitial() || TasksLoading() => const _LoadingView(),

            TasksEmpty() => _MessageView(
              icon: Icons.inbox_outlined,
              title: AppStrings.noTasksYet,
              message: AppStrings.tasksWillAppearHere,
              actionLabel: AppStrings.refresh,
              onAction: () => _bloc.add(const TasksRefreshed()),
            ),

            TasksFailure(:final message) => _MessageView(
              icon: Icons.error_outline_rounded,
              title: AppStrings.somethingWentWrong,
              message: message,
              actionLabel: AppStrings.tryAgain,
              onAction: () => _bloc.add(const TasksRefreshed()),
            ),

            TasksLoaded() => _buildGrid(state),
          };
        },
      ),
    );
  }

  Widget _buildGrid(TasksLoaded state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: _columnCount(constraints.maxWidth),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: state.tasks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CreateTaskCard(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => const CreateTaskDialog(),
                          );
                        },
                      );
                    }

                    final int taskIndex = index - 1;

                    return TaskCard(
                      task: state.tasks[taskIndex],
                      onTap: () => _openTask(state.tasks[taskIndex].id),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: _ListFooter(state: state)),
            ],
          );
        },
      ),
    );
  }
}

/// Full-screen loader with a text label.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppStrings.loadingTasks,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Big centered icon + title + message + action.
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 112, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom of the list: load-more spinner, load-more error, or end marker.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final TasksLoaded state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final TextStyle? textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget child;

    if (state.isLoadingMore) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(AppStrings.loadingMoreTasks, style: textStyle),
        ],
      );
    } else if (state.loadMoreFailed) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error),
          const SizedBox(height: 4),
          Text(
            state.errorMessage ?? AppStrings.couldNotLoadMoreTasks,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ],
      );
    } else if (!state.hasMore) {
      child = Text(
        AppStrings.allTasksLoaded,
        textAlign: TextAlign.center,
        style: textStyle,
      );
    } else {
      child = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: child,
    );
  }
}
