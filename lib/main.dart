import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/firebase/firebase_bootstrap.dart';
import 'package:mobile_assignment/feature/auth/services/local_auth_service.dart';
import 'package:mobile_assignment/feature/tasks/screens/task_screen.dart';

import 'feature/auth/screens/login_screen.dart';
import 'feature/auth/screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  await LocalAuthService.instance.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Assignment',
      initialRoute: LoginScreen.routeName,
      routes: <String, WidgetBuilder>{
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        TaskScreen.routeName: (_) => const TaskScreen(),
      },
    );
  }
}
