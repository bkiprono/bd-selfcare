import 'package:flutter/material.dart';
import 'package:bdcomputing/core/styles.dart';

class CustomPickerField extends StatelessWidget {
  final String label;
  final String value;
  final String hintText;
  final IconData? prefixIcon;
  final VoidCallback onTap;
  final bool isRequired;
  final bool isLoading;
  final String? errorText;

  const CustomPickerField({
    super.key,
    required this.label,
    required this.value,
    this.hintText = 'Select an option',
    this.prefixIcon,
    required this.onTap,
    this.isRequired = false,
    this.isLoading = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
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
        const SizedBox(height: 8),
        InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: errorText != null ? AppColors.error : Colors.grey[200]!,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : hintText,
                    style: TextStyle(
                      fontSize: 15,
                      color: value.isNotEmpty ? const Color(0xFF1A1A1A) : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
