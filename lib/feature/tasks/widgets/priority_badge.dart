

import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/style/colors.dart';

class PriorityBadge extends StatelessWidget {
  final String label;

  const PriorityBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.button,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.button,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}