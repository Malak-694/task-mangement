

import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/style/colors.dart';

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool isPassword;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isPassword ? 20 : 16,
            color: AppColors.text,
            letterSpacing: isPassword ? 4 : 0,
          ),
        ),
        const SizedBox(height: 14),
        Divider(color: AppColors.primary.withOpacity(0.3), height: 1),
        const SizedBox(height: 18),
      ],
    );
  }
}