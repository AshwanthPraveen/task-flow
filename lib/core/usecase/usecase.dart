// ============================================================================
// File: usecase.dart
// Created Date: 27-Sep-2026
// Title: UseCase
// Description:
//   Base contract for all use cases. Returns Either a Failure or a result.
//
// Class:
//   UseCase
//   NoParams
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:task_flow/core/errors/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
