// ============================================================================
// File: app_text_field.dart
// Created Date: 27-Sep-2026
// Title: AppTextField
// Description:
//   Provides a reusable text field component with consistent application
//   styling. Supports labels, hints, prefixes, suffixes, validation,
//   password input, keyboard configuration, and responsive sizing.
//
// Class:
//   AppTextField
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.device,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;

  final String? label;
  final String? hint;

  final ResponsiveDevice? device;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;

  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final int maxLines;
  final int? minLines;
  final int? maxLength;

  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final currentDevice = device ?? Responsive.device(context);

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      onTap: onTap,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
        fontSize: _fontSize(currentDevice),
      ),
      cursorColor: AppColors.primaryLight,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontSize: _fontSize(currentDevice),
        ),
        hintStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
          fontSize: _fontSize(currentDevice),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textMuted, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: _contentPadding(currentDevice),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _focusedBorder(),
        errorBorder: _errorBorder(),
        focusedErrorBorder: _errorBorder(),
        disabledBorder: _disabledBorder(),
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error, width: 1.2),
    );
  }

  OutlineInputBorder _disabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
    );
  }

  EdgeInsets _contentPadding(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      ResponsiveDevice.tablet => const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      ResponsiveDevice.desktop => const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      ResponsiveDevice.ultraHd => const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
    };
  }

  double _fontSize(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 14,
      ResponsiveDevice.tablet => 14,
      ResponsiveDevice.desktop => 15,
      ResponsiveDevice.ultraHd => 16,
    };
  }
}
