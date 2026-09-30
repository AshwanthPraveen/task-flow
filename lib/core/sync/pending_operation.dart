// ============================================================================
// File: pending_operation.dart
// Created Date: 01-Oct-2026
// Title: PendingOperation
// Description:
//   Kinds of change that can wait in the pending_changes queue. The name is
//   stored in the "operation" column.
//
// Class:
//   PendingOperation
// ============================================================================

enum PendingOperation { create, update, delete }
