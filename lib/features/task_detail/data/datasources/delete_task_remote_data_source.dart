// ============================================================================
// File: delete_task_remote_data_source.dart
// Created Date: 30-Sep-2026
// Title: DeleteTaskRemoteDataSource
// Description:
//   Contract for calling the delete task API.
//
// Class:
//   DeleteTaskRemoteDataSource
//
// Author: Ashwanth V Praveen
// ============================================================================

abstract class DeleteTaskRemoteDataSource {
  Future<void> deleteTask(int id);
}
