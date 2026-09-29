import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/main.dart';

void main() {
  testWidgets('Task Flow app starts successfully', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.byType(TaskFlowApp), findsOneWidget);
  });
}
