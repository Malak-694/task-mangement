// lib/feature/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/style/colors.dart';
import '../../../core/validator/auth_validator.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_text_field.dart';
import '../../tasks/screens/task_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await context.read<AuthProvider>().login(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, TaskScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Sign In', style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              const Text('Welcome back',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 8),
              const Text('Log in with your university credentials',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              AppTextField(
                controller: _emailCtrl,
                label: 'University Email',
                hint: '12345678@stud.fci-cu.edu.eg',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => AuthValidator.required(v, 'Email'),
              ),
              AppTextField(
                controller: _passwordCtrl,
                label: 'Password',
                obscure: true,
                validator: (v) => AuthValidator.required(v, 'Password'),
              ),

              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Log In',
                      style: TextStyle(color: AppColors.buttonText, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pushNamed(context, SignupScreen.routeName),
                child: const Text('No account? Create one'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}