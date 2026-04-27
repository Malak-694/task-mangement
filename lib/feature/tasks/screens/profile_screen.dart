// lib/feature/tasks/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/auth/providers/auth_provider.dart';
import 'package:mobile_assignment/feature/auth/screens/login_screen.dart';
import 'package:mobile_assignment/feature/tasks/providers/profile_provider.dart';
import 'package:mobile_assignment/feature/tasks/screens/edit_screen.dart';
import 'package:mobile_assignment/feature/tasks/widgets/ProfileField.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileProvider>().loadUser());
  }

  Future<void> _logout() async {
    await context.read<ProfileProvider>().logout(context.read<AuthProvider>());
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('← Back', style: TextStyle(color: AppColors.primary, fontSize: 14)),
        ),
        leadingWidth: 80,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.pushNamed(context, EditProfileScreen.routeName);
            },
            child: const Text('Edit', style: TextStyle(color: AppColors.button, fontSize: 14)),
          ),
        ],
      ),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          const SizedBox(height: 20),

          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: _buildAvatar(profile.avatarPath),
          ),

          const SizedBox(height: 28),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ProfileField(label: 'Full Name',         value: profile.name      ?? '—'),
                ProfileField(label: 'University Email',  value: profile.email     ?? '—'),
                ProfileField(label: 'Student ID',        value: profile.studentId ?? '—'),
                const ProfileField(label: 'Password', value: '••••••••', isPassword: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.buttonText),
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

  Widget _buildAvatar(String? path) {
    if (path == null) {
      return const Icon(Icons.person_outline_rounded, size: 50, color: AppColors.primary);
    }
    if (path.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          path, width: 120, height: 120, fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
          progress == null ? child : const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.person_outline_rounded, size: 50, color: AppColors.primary),
        ),
      );
    }
    if (File(path).existsSync()) {
      return ClipOval(child: Image.file(File(path), width: 120, height: 120, fit: BoxFit.cover));
    }
    return const Icon(Icons.person_outline_rounded, size: 50, color: AppColors.primary);
  }
}