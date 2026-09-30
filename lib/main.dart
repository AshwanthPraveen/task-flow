import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/create_task/presentation/bloc/create_task_bloc.dart';
import 'package:task_flow/features/task_detail/presentation/bloc/task_detail_bloc.dart';
import 'package:task_flow/features/tasks_home/presentation/bloc/tasks_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (_) => getIt<LoginBloc>()),
        BlocProvider<TasksBloc>(create: (_) => getIt<TasksBloc>()),
        BlocProvider<CreateTaskBloc>(create: (_) => getIt<CreateTaskBloc>()),
        BlocProvider<TaskDetailBloc>(create: (_) => getIt<TaskDetailBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Task Flow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
