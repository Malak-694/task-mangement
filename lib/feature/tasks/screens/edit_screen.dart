// lib/feature/tasks/screens/edit_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/core/validator/auth_validator.dart';
import 'package:mobile_assignment/feature/tasks/providers/profile_provider.dart';
import 'package:mobile_assignment/feature/tasks/widgets/edit_field.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _nameController.text      = profile.name      ?? '';
    _studentIdController.text = profile.studentId ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<ProfileProvider>().updateUser(
      name:       _nameController.text.trim(),
      studentId:  _studentIdController.text.trim(),
      password:   _passwordController.text.trim(),
      avatarFile: _pickedImage,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
      backgroundColor: success ? AppColors.primary : AppColors.button,
    ));

    if (success) Navigator.pop(context, true);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 512);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
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
          'Edit Profile',
          style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: _buildAvatar(profile.avatarPath),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.camera_alt_rounded, size: 15, color: AppColors.background),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  EditField(label: 'NAME',
                      controller: _nameController,
                      validator: AuthValidator.fullName),
                  EditField(label: 'STUDENT ID',
                      controller: _studentIdController,
                      validator: AuthValidator.studentId),
                  EditField(
                    label:      'PASSWORD',
                    controller: _passwordController,
                    hint:       'Leave empty to keep current password',
                    obscure:    true,
                    validator:  (v) => v != null && v.isNotEmpty ? AuthValidator.password(v) : null,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: AppColors.primary.withOpacity(0.5)
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: profile.isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: profile.isSaving
                        ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? savedPath) {
    if (_pickedImage != null) {
      return ClipOval(child: Image.file(_pickedImage!, width: 120, height: 120, fit: BoxFit.cover));
    }
    if (savedPath != null && File(savedPath).existsSync()) {
      return ClipOval(child: Image.file(File(savedPath), width: 120, height: 120, fit: BoxFit.cover));
    }
    return const Icon(Icons.person_outline_rounded, size: 40, color: AppColors.primary);
  }
}