


import 'package:flutter/material.dart';

import '../../../core/style/colors.dart';

class Label extends StatelessWidget {
  final String text;
  final bool required;
  const Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,
        color: AppColors.text, letterSpacing: 0.8)),
    if (required)
      Text(' *', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.button.withOpacity(0.8), letterSpacing: 0.8)),
  ]);
}
