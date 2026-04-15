import 'package:flutter/material.dart';
import 'package:mobile_assignment/feature/auth/widgets/app_text_field.dart';

import '../../../core/style/colors.dart';
import '../../../core/validator/auth_validator.dart';
import '../../tasks/screens/task_screen.dart';
import '../services/hybrid_auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _gender;
  int? _academicLevel;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final String email = _emailController.text.trim();
    final String studentId = _studentIdController.text.trim();
    final RegExp pattern = RegExp(r'^(\d+)@stud\.fci-cu\.edu\.eg$');
    final Match? match = pattern.firstMatch(email);
    final String emailStudentId = match?.group(1) ?? '';

    if (emailStudentId != studentId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signup Failure: email Student ID must match Student ID field.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await HybridAuthService.instance.signUp(
        name: _fullNameController.text.trim(),
        gender: _gender,
        email: email,
        studentId: studentId,
        level: _academicLevel,
        password: _passwordController.text,
      );
      if (!mounted) {//if the widget is not active any more stop
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      if (result.isSuccess) {
        Navigator.pushReplacementNamed(context, TaskScreen.routeName);
      }
    } finally {
      if (mounted) { 
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Welcome ',
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

              /// Full Name
              AppTextField(
                controller: _fullNameController,
                label: 'Full Name',
                validator: AuthValidator.fullName,
              ),

              /// Gender
              _buildGenderSection(),

              /// Email
              AppTextField(
                controller: _emailController,
                label: 'University Email',
                hint: '12345678@stud.fci-cu.edu.eg',
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidator.universityEmail,
              ),

              /// Student ID
              AppTextField(
                controller: _studentIdController,
                label: 'Student ID',
                keyboardType: TextInputType.number,
                validator: AuthValidator.studentId,
              ),

              /// Academic Level
              _buildLevelDropdown(),

              /// Password
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                obscure: true,
                validator: AuthValidator.password,
              ),

              /// Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                obscure: true,
                validator: (value) => AuthValidator.confirmPassword(
                  value,
                  _passwordController.text,
                ),
              ),

              const SizedBox(height: 10),

              /// Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _signup,
                  child: _isSubmitting
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
                onPressed: _isSubmitting
                    ? null
                    : () {
                        final NavigatorState nav = Navigator.of(context);
                        if (nav.canPop()) {
                          nav.pop();
                        } else {
                          nav.pushReplacementNamed(LoginScreen.routeName);
                        }
                      },
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelDropdown() {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: _academicLevel,
          decoration: InputDecoration(
            labelText: 'Academic Level',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [1, 2, 3, 4]
              .map(
                (level) => DropdownMenuItem(
                  value: level,
                  child: Text(level.toString()),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _academicLevel = value),
        ),
        const SizedBox(height: 16),
      ],
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
          onChanged: (String? value) => setState(() => _gender = value),
          child: Row(
            children: const <Widget>[
              Expanded(
                child: RadioListTile<String>(
                  value: 'Male',
                  title: Text('Male'),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  value: 'Female',
                  title: Text('Female'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
