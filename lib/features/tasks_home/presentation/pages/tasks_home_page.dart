// ============================================================================
// File: tasks_page.dart
// Created Date: 27-Sep-2026
// Title: TasksPage
// Description:
//   Sample tasks page that uses TaskFlowAppBar and shows a static list of
//   tasks. Replace the sample data with real data later.
//
// Class:
//   TasksPage
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/widgets/app_bar.dart';

class TasksHomePage extends StatelessWidget {
  const TasksHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TaskFlowAppBar(title: 'Tasks Home'),
      body: Center(),
    );
  }
}
