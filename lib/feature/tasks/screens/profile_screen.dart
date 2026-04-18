import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/session_manager.dart';
import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/auth/screens/login_screen.dart';
import 'package:mobile_assignment/feature/tasks/Services/profile_service.dart';
import 'package:mobile_assignment/feature/tasks/screens/edit_screen.dart';
import 'package:mobile_assignment/feature/tasks/widgets/ProfileField.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final email = SessionManager.instance.currentUserEmail;
    if (email != null) {
      final user = await ProfileService.instance.getUserByEmail(email);
      setState(() {
        _user = user;
        _avatarPath = user?['avatar_path'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _logout() {
    SessionManager.instance.clearUser();
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '← Back',
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              final updated = await Navigator.pushNamed(
                context,
                EditProfileScreen.routeName,
              );
              if (updated == true) _loadUser();
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: AppColors.button, fontSize: 14),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          const SizedBox(height: 20),
          // In ProfileScreen build() method:

          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: _avatarPath != null
                ? (_avatarPath!.startsWith('http')
                ? ClipOval(
              child: Image.network(
                _avatarPath!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(' Error loading avatar: $error');
                  return const Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    color: AppColors.primary,
                  );
                },
              ),
            ) : File(_avatarPath!).existsSync()
                ? ClipOval(
              child: Image.file(
                File(_avatarPath!),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            )
                : const Icon(
              Icons.person_outline_rounded,
              size: 50,
              color: AppColors.primary,
            ))
                : const Icon(
              Icons.person_outline_rounded,
              size: 50,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 28),

          // Fields
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ProfileField(
                  label: 'Full Name',
                  value: _user?['name'] ?? '—',
                ),
                ProfileField(
                  label: 'University Email',
                  value: _user?['email'] ?? '—',
                ),
                ProfileField(
                  label: 'Student ID',
                  value: _user?['student_id'] ?? '—',
                ),
                const ProfileField(
                  label: 'Password',
                  value: '••••••••',
                  isPassword: true,
                ),
              ],
            ),
          ),

          // Logout button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.buttonText,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}