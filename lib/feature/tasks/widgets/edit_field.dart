


import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/style/colors.dart';

class EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  const EditField({
    required this.label,
    required this.controller,
    this.readOnly = false,
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
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 16,
            color: readOnly ? AppColors.text.withOpacity(0.5) : AppColors.text,
          ),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}