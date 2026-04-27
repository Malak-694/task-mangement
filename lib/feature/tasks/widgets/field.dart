import 'package:flutter/material.dart';

import '../../../core/style/colors.dart';

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  const Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    focusNode: focusNode,
    maxLines: maxLines,
    validator: validator,
    textInputAction: textInputAction,
    onFieldSubmitted: onFieldSubmitted,
    style: TextStyle(fontSize: 15, color: AppColors.text),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 15, color: AppColors.text),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.text),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.button),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.button, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 12, color: AppColors.button),
      contentPadding: const EdgeInsets.only(bottom: 8),
      isDense: true,
    ),
  );
}
