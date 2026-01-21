import 'package:flutter/material.dart';
import 'package:bdcomputing/core/styles.dart';

class CustomLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  final EdgeInsetsGeometry? padding;

  const CustomLabel({
    super.key,
    required this.text,
    this.isRequired = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppTextStyles.body1(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}
