// ============================================================================
// File: pending_changes_table.dart
// Created Date: 01-Oct-2026
// Title: PendingChangesTable
// Description:
//   Drift table for the queue of changes made offline that still have to be
//   sent to the server. Fields after operation are nullable so a delete
//   operation can be added later without a schema change.
//
// Class:
//   PendingChangesTable
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:drift/drift.dart';

@DataClassName('PendingChangeRow')
class PendingChangesTable extends Table {
  @override
  String get tableName => 'pending_changes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  IntColumn get taskId => integer()();
  TextColumn get localId => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get baseVersion => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
