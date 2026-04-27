// lib/feature/auth/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/style/colors.dart';
import '../../../core/validator/auth_validator.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_text_field.dart';
import '../../tasks/screens/task_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _studentIdFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _gender;
  int? _academicLevel;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _studentIdCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _studentIdFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    // Cross-field check: email student ID must match student ID field
    final email = _emailCtrl.text.trim();
    final studentId = _studentIdCtrl.text.trim();
    final match = RegExp(r'^(\d+)@stud\.fci-cu\.edu\.eg$').firstMatch(email);

    if ((match?.group(1) ?? '') != studentId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signup Failure: email Student ID must match Student ID field.',
          ),
        ),
      );
      return;
    }

    final result = await context.read<AuthProvider>().signUp(
      name: _fullNameCtrl.text.trim(),
      gender: _gender,
      email: email,
      studentId: studentId,
      level: _academicLevel,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

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
        title: const Text(
          'Create Account',
          style: TextStyle(color: AppColors.text),
        ),
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
                'Welcome',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your account to continue',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              AppTextField(
                controller: _fullNameCtrl,
                focusNode: _fullNameFocus,
                label: 'Full Name',
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocus),
                validator: AuthValidator.fullName,
              ),
              _buildGenderSection(),
              AppTextField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                label: 'University Email',
                hint: '12345678@stud.fci-cu.edu.eg',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_studentIdFocus),
                validator: AuthValidator.universityEmail,
              ),
              AppTextField(
                controller: _studentIdCtrl,
                focusNode: _studentIdFocus,
                label: 'Student ID',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                validator: AuthValidator.studentId,
              ),
              _buildLevelDropdown(),
              AppTextField(
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                label: 'Password',
                obscure: true,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                validator: AuthValidator.password,
              ),
              AppTextField(
                controller: _confirmPasswordCtrl,
                focusNode: _confirmPasswordFocus,
                label: 'Confirm Password',
                obscure: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signup(),
                validator: (v) =>
                    AuthValidator.confirmPassword(v, _passwordCtrl.text),
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
                  onPressed: isLoading ? null : _signup,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final nav = Navigator.of(context);
                        nav.canPop()
                            ? nav.pop()
                            : nav.pushReplacementNamed(LoginScreen.routeName);
                      },
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender (Optional)',
          style: TextStyle(color: AppColors.text),
        ),
        RadioGroup<String>(
          groupValue: _gender,
          onChanged: (v) => setState(() => _gender = v),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  value: 'Male',
                  title: const Text('Male'),
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  value: 'Female',
                  title: const Text('Female'),
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLevelDropdown() {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _academicLevel,
          decoration: InputDecoration(
            labelText: 'Academic Level',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [1, 2, 3, 4]
              .map((l) => DropdownMenuItem(value: l, child: Text(l.toString())))
              .toList(),
          onChanged: (v) => setState(() => _academicLevel = v),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
