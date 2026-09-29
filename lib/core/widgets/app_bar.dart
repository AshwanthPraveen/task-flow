// ============================================================================
// File: task_flow_app_bar.dart
// Created Date: 27-Sep-2026
// Title: TaskFlowAppBar
// Description:
//   Common app bar showing the page title, the logged in user's name from
//   saved user details and a logout action that clears the session.
//
// Class:
//   TaskFlowAppBar
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:task_flow/core/di/injection.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/theme/app_spacing.dart';
import 'package:task_flow/core/theme/app_text_styles.dart';
import 'package:task_flow/core/widgets/app_icon_button.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_bloc.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_event.dart';

class TaskFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const TaskFlowAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);
  static const double _dividerHeight = 0.5;

  Future<void> _onLogout(BuildContext context) async {
    await getIt<UserDetails>().clear();
    if (!context.mounted) return;
    context.read<LoginBloc>().add(const LoginStatusReset());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final String userName = getIt<UserDetails>().userName ?? '';

    return AppBar(
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(_dividerHeight),
        child: Divider(
          height: _dividerHeight,
          thickness: _dividerHeight,
          color: AppColors.border,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.lg,
      leading: showBackButton
          ? AppIconButton(
              onPressed: onBackPressed,
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
            )
          : null,
      title: Text(title, style: AppTextStyles.heading2),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: Center(
            child: Text(
              userName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        AppIconButton(
          onPressed: () => _onLogout(context),
          icon: Icons.logout_rounded,
          tooltip: 'Logout',
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
