// ============================================================================
// File: app_database.dart
// Created Date: 01-Oct-2026
// Title: AppDatabase
// Description:
//   Drift database for TaskFlow. Holds the local task cache and the queue of
//   pending offline changes.
//
// Class:
//   AppDatabase
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:task_flow/core/database/tables/pending_changes_table.dart';
import 'package:task_flow/core/database/tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TasksTable, PendingChangesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'taskflow'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
