// ============================================================================
// File: login_bloc.dart
// Created Date: 27-Sep-2026
// Title: LoginBloc
// Description:
//   Handles login screen logic: live email and password validation,
//   password visibility, login submit through LoginUseCase and status
//   reset.
//
// Class:
//   LoginBloc
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/core/storage/user_details.dart';

import 'package:task_flow/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_event.dart';
import 'package:task_flow/features/auth/presentation/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this._loginUseCase, required this._userDetails})
    : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginStatusReset>(_onStatusReset);
  }
  final LoginUseCase _loginUseCase;
  final UserDetails _userDetails;

  static const int _minPasswordLength = 8;

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );
  static final RegExp _digitRegex = RegExp(r'\d');

  String? _validateEmail(String value) {
    final String email = value.trim();
    if (email.isEmpty) return null;
    if (!_emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return null;
    if (value.length < _minPasswordLength) {
      return 'Password must be at least $_minPasswordLength characters';
    }
    if (!_digitRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final String? error = _validateEmail(event.email);
    emit(
      state.copyWith(
        email: event.email,
        emailError: error,
        clearEmailError: error == null,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final String? error = _validatePassword(event.password);
    emit(
      state.copyWith(
        password: event.password,
        passwordError: error,
        clearPasswordError: error == null,
      ),
    );
  }

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isFormValid || state.isLoading) return;

    emit(state.copyWith(status: LoginStatus.loading, clearErrorMessage: true));

    final result = await _loginUseCase(
      LoginParams(email: state.email.trim(), password: state.password),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (auth) async {
        try {
          await _userDetails.saveSession(
            accessToken: auth.accessToken,
            tokenType: auth.tokenType,
            userId: auth.user.id,
            userName: auth.user.name,
            userEmail: auth.user.email,
          );
          emit(state.copyWith(status: LoginStatus.success, auth: auth));
        } catch (_) {
          emit(
            state.copyWith(
              status: LoginStatus.failure,
              errorMessage: 'Could not save your session. Please try again.',
            ),
          );
        }
      },
    );
  }

  void _onStatusReset(LoginStatusReset event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: LoginStatus.initial, clearErrorMessage: true));
  }
}
