// lib/feature/tasks/screens/edit_profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_assignment/core/session_manager.dart';
import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/tasks/Services/profile_service.dart';
import 'package:mobile_assignment/feature/tasks/widgets/edit_field.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _email;
  File? _pickedImage;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _email = SessionManager.instance.currentUserEmail;
    if (_email != null) {
      final user = await ProfileService.instance.getUserByEmail(_email!);
      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _studentIdController.text = user['student_id'] ?? '';
        setState(() {
          _avatarPath = user['avatar_path'] ?? null;       // 👈 load saved path
          _loading = false;
        });
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveChanges() async {
    if (_email == null) return;
    setState(() => _saving = true);

    final success = await ProfileService.instance.updateUser(
      email: _email!,
      name: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      avatarFile: _pickedImage,
    );

    setState(() => _saving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context, true); // true = refresh profile
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: AppColors.button,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

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
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: _pickedImage != null
                    ? ClipOval(
                  child: Image.file(
                    _pickedImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                )
                    : (_avatarPath != null && File(_avatarPath!).existsSync()
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
                  size: 40,
                  color: AppColors.primary,
                )),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child:  Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Editable fields
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                EditField(label: 'NAME', controller: _nameController),
                EditField(
                  label: 'STUDENT ID',
                  controller: _studentIdController,
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Save Changes
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}