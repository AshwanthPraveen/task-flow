// ============================================================================
// File: update_task_request_model.dart
// Created Date: 30-Sep-2026
// Title: UpdateTaskRequestModel
// Description:
//   Request body for PUT /tasks/{id}. Null description is omitted.
//
// Class:
//   UpdateTaskRequestModel
//
// Author: Ashwanth V Praveen
// ============================================================================

class UpdateTaskRequestModel {
  const UpdateTaskRequestModel({
    required this.title,
    required this.status,
    required this.version,
    this.description,
  });

  final String title;
  final String? description;
  final String status;
  final int version;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'status': status,
      'version': version,
    };
  }
}
