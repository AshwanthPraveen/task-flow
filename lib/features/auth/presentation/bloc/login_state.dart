// ============================================================================
// File: login_state.dart
// Created Date: 27-Sep-2026
// Title: LoginState
// Description:
//   Single state for the login screen holding field values, validation
//   errors, password visibility, request status, error message and the
//   auth result.
//
// Class:
//   LoginStatus
//   LoginState
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/features/auth/domain/entities/auth_entity.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isPasswordVisible = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.auth,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isPasswordVisible;
  final LoginStatus status;
  final String? errorMessage;
  final AuthEntity? auth;

  bool get isLoading => status == LoginStatus.loading;

  bool get isFormValid =>
      email.trim().isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? isPasswordVisible,
    LoginStatus? status,
    String? errorMessage,
    AuthEntity? auth,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearErrorMessage = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      auth: auth ?? this.auth,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    emailError,
    passwordError,
    isPasswordVisible,
    status,
    errorMessage,
    auth,
  ];
}
