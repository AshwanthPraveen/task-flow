// ============================================================================
// File: tasks_table.dart
// Created Date: 01-Oct-2026
// Title: TasksTable
// Description:
//   Drift table that stores a local copy of every task, including its sync
//   state. Offline-created tasks use a negative temporary id until the server
//   assigns a real one.
//
// Class:
//   TasksTable
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:drift/drift.dart';

@DataClassName('TaskRow')
class TasksTable extends Table {
  @override
  String get tableName => 'tasks';

  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get createdBy => integer()();
  IntColumn get version => integer()();
  TextColumn get localId => text().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
