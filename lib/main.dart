import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/firebase/firebase_bootstrap.dart';
import 'package:mobile_assignment/feature/auth/services/local_auth_service.dart';
import 'package:mobile_assignment/feature/tasks/Services/task_reprositry.dart';
import 'package:mobile_assignment/feature/tasks/screens/edit_screen.dart';
import 'package:mobile_assignment/feature/tasks/screens/new_task_screen.dart';
import 'package:mobile_assignment/feature/tasks/screens/profile_screen.dart';
import 'package:mobile_assignment/feature/tasks/screens/task_screen.dart';
import 'package:provider/provider.dart';

import 'core/session_manager.dart';
import 'feature/auth/providers/auth_provider.dart';
import 'feature/auth/screens/login_screen.dart';
import 'feature/auth/screens/signup_screen.dart';
import 'feature/tasks/Services/local_task_service.dart';
import 'feature/tasks/providers/profile_provider.dart';
import 'feature/tasks/providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  await LocalAuthService.instance.init();
  await LocalTaskService.instance.init();
  TaskRepository.instance.setUser(null);
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: const MainApp(),
      ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    final startRoute = SessionManager.instance.currentUserEmail != null
        ? TaskScreen.routeName
        : LoginScreen.routeName;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Assignment',
      initialRoute:startRoute,
      routes: <String, WidgetBuilder>{
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        TaskScreen.routeName: (_) => const TaskScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        ProfileScreen.routeName: (_) => ProfileScreen(),
        NewTaskScreen.routeName: (_) => NewTaskScreen(),
      },
    );
  }
}
