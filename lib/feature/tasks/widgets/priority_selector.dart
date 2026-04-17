// lib/feature/tasks/widgets/priority_selector.dart

import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/style/colors.dart';

class PrioritySelector extends FormField<String> {
  PrioritySelector({
    super.key,
    super.initialValue = 'medium',
    super.validator,
    ValueChanged<String>? onChanged,
  }) : super(
    builder: (state) {
      final value = state.value ?? initialValue ?? 'medium';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['low', 'medium', 'high'].map((opt) {
              final selected = opt == value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: opt != 'high' ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      state.didChange(opt);
                      onChanged?.call(opt);
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.text : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? AppColors.text
                              : AppColors.text.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        opt.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? AppColors.background
                              : AppColors.text.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                state.errorText!,
                style: const TextStyle(fontSize: 12, color: AppColors.button),
              ),
            ),
        ],
      );
    },
  );
}