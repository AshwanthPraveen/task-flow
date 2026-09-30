// ============================================================================
// File: sync_remote_data_source.dart
// Created Date: 01-Oct-2026
// Title: SyncRemoteDataSource
// Description:
//   Contract for the bulk sync endpoint.
//
// Class:
//   SyncRemoteDataSource
// ============================================================================

import 'package:task_flow/core/sync/sync_models.dart';

abstract class SyncRemoteDataSource {
  /// POST /sync. Returns one result per change.
  Future<List<SyncResultModel>> sync(List<SyncOperationModel> changes);
}
