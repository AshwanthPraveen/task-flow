// ============================================================================
// File: task_sync_state.dart
// Created Date: 01-Oct-2026
// Title: TaskSyncState
// Description:
//   Sync state of a task relative to the server. Used by the offline feature
//   to show which tasks are waiting to be synced.
//
// Class:
//   TaskSyncState
//
// Author: Ashwanth V Praveen
// ============================================================================

enum TaskSyncState { synced, pendingCreate, pendingUpdate, failed }
