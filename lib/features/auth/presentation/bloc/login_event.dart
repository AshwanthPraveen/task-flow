// ============================================================================
// File: login_event.dart
// Created Date: 27-Sep-2026
// Title: LoginEvent
// Description:
//   Events handled by LoginBloc: field changes, password visibility
//   toggle, submit and status reset.
//
// Class:
//   LoginEvent
//   LoginEmailChanged
//   LoginPasswordChanged
//   LoginPasswordVisibilityToggled
//   LoginSubmitted
//   LoginStatusReset
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => [password];
}

class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginStatusReset extends LoginEvent {
  const LoginStatusReset();
}
