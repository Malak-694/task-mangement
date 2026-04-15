import 'package:flutter/material.dart';
import 'package:mobile_assignment/feature/auth/widgets/app_text_field.dart';

import '../../../core/style/colors.dart';
import '../../../core/validator/auth_validator.dart';
import '../services/hybrid_auth_service.dart';
import '../../tasks/screens/task_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await HybridAuthService.instance.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (!result.isSuccess) {
      return;
    }

    Navigator.pushReplacementNamed(context, TaskScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log in with your university credentials',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              AppTextField(
                controller: _emailController,
                label: 'University Email',
                hint: '12345678@stud.fci-cu.edu.eg',
                keyboardType: TextInputType.emailAddress,
                validator: (String? value) =>
                    AuthValidator.required(value, 'Email'),
              ),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                obscure: true,
                validator: (String? value) =>
                    AuthValidator.required(value, 'Password'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, SignupScreen.routeName);
                      },
                child: const Text('No account? Create one'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
