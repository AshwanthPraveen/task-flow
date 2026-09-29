file

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/core/constants/app_strings.dart';
import 'package:task_flow/core/responsive/responsive.dart';
import 'package:task_flow/core/router/app_router.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/theme/app_font_sizes.dart';
import 'package:task_flow/core/theme/app_spacing.dart';
import 'package:task_flow/core/theme/app_text_styles.dart';
import 'package:task_flow/core/widgets/app_button.dart';
import 'package:task_flow/core/widgets/app_text_field.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_bloc.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_event.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const double _errorSlotHeight = 24;
  @override
  Widget build(BuildContext context) {
    final device = Responsive.device(context);

    final bool isMobile = device == ResponsiveDevice.mobile;
    final bool isTablet = device == ResponsiveDevice.tablet;

    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double cardWidth = isMobile
        ? screenWidth - (AppSpacing.lg * 2)
        : isTablet
        ? 440
        : 420;

    final double cardPadding = isMobile ? AppSpacing.lg : AppSpacing.xl;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.sizeOf(context).height - (AppSpacing.lg * 2),
              ),
              child: Center(
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: AppSpacing.xl,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBrand(isMobile),
                      const SizedBox(height: AppSpacing.xl),
                      _buildWelcome(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildForm(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onStatusChanged(BuildContext context, LoginState state) {
    if (state.status == LoginStatus.success) {
      context.go(AppRouter.tasks);
    }
  }

  Widget _buildBrand(bool isMobile) {
    final double logoSize = isMobile ? 48 : 52;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: AppSpacing.lg,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, size: 26, color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading1.copyWith(
            fontSize: isMobile ? 30 : AppFontSizes.heading1,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.appTagline,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWelcome() {
    return Column(
      children: [
        Text(AppStrings.welcomeBack, style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.loginSubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmailField(context, state),
            _buildErrorText(state.emailError),
            _buildPasswordField(context, state),
            _buildErrorText(state.passwordError),
            const SizedBox(height: AppSpacing.md),
            _buildLoginButton(context, state),
            _buildApiError(state.errorMessage),
          ],
        );
      },
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

  Widget _buildEmailField(BuildContext context, LoginState state) {
    return AppTextField(
      hint: AppStrings.email,
      prefixIcon: Icons.mail_outline_rounded,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !state.isLoading,
      onChanged: (value) =>
          context.read<LoginBloc>().add(LoginEmailChanged(value)),
    );
  }

  Widget _buildPasswordField(BuildContext context, LoginState state) {
    return AppTextField(
      hint: AppStrings.password,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: !state.isPasswordVisible,
      textInputAction: TextInputAction.done,
      enabled: !state.isLoading,
      suffixIcon: IconButton(
        onPressed: () => context.read<LoginBloc>().add(
          const LoginPasswordVisibilityToggled(),
        ),
        icon: Icon(
          state.isPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textMuted,
          size: 19,
        ),
      ),
      onChanged: (value) =>
          context.read<LoginBloc>().add(LoginPasswordChanged(value)),
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

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    return AppButton(
      label: AppStrings.login,
      isDisabled: !state.isFormValid,
      isFullWidth: true,
      isLoading: state.isLoading,
      onPressed: state.isFormValid
          ? () => context.read<LoginBloc>().add(const LoginSubmitted())
          : null,
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xxs),
        Text(AppStrings.secureTaskManagement, style: AppTextStyles.caption),
      ],
    );
  }
}
