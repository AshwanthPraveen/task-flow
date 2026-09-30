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
import 'package:task_flow/core/responsive/responsive.dart';
import 'package:task_flow/core/router/app_router.dart';
import 'package:task_flow/core/socket/task_socket_service.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/theme/app_font_sizes.dart';
import 'package:task_flow/core/theme/app_spacing.dart';
import 'package:task_flow/core/theme/app_text_styles.dart';
import 'package:task_flow/core/widgets/app_icon_button.dart';
import 'package:task_flow/core/constants/app_strings.dart';
import 'package:task_flow/core/widgets/logout_confirm_dialog.dart';
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

  static const double _dividerHeight = 0.5;

  double _appBarHeight(BuildContext context) {
    switch (Responsive.device(context)) {
      case ResponsiveDevice.mobile:
        return 56;

      case ResponsiveDevice.tablet:
        return 60;

      case ResponsiveDevice.desktop:
        return 64;

      case ResponsiveDevice.ultraHd:
        return 72;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);

  Future<void> _onLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmDialog(),
    );

    if (confirmed != true || !context.mounted) return;
    // Disconnect from socket
    getIt<TaskSocketService>().disconnect();
    // Clear user data
    await getIt<UserDetails>().clear();

    if (!context.mounted) return;

    context.read<LoginBloc>().add(const LoginStatusReset());
    context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final String userName = getIt<UserDetails>().userName ?? '';

    final double appBarHeight = _appBarHeight(context);

    final double titleSize;
    final double userNameSize;

    switch (Responsive.device(context)) {
      case ResponsiveDevice.mobile:
        titleSize = AppFontSizes.subtitleMobile;
        userNameSize = AppFontSizes.captionMobile;
        break;

      case ResponsiveDevice.tablet:
        titleSize = AppFontSizes.subtitleTablet;
        userNameSize = AppFontSizes.captionTablet;
        break;

      case ResponsiveDevice.desktop:
        titleSize = AppFontSizes.heading2;
        userNameSize = AppFontSizes.bodySmall;
        break;

      case ResponsiveDevice.ultraHd:
        titleSize = AppFontSizes.subtitleUltraHd;
        userNameSize = AppFontSizes.bodyUltraHd;
        break;
    }

    return AppBar(
      toolbarHeight: appBarHeight,
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
      title: Row(
        spacing: AppSpacing.sm,
        children: [
          showBackButton
              ? AppIconButton(
                  onPressed: onBackPressed,
                  icon: Icons.arrow_back_ios_rounded,
                  tooltip: AppStrings.back,
                )
              : const SizedBox.shrink(),
          Text(
            title,
            style: AppTextStyles.heading2.copyWith(fontSize: titleSize),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: Center(
            child: Text(
              userName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: userNameSize,
              ),
            ),
          ),
        ),
        AppIconButton(
          onPressed: () => _onLogout(context),
          icon: Icons.logout_rounded,
          tooltip: AppStrings.logout,
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
