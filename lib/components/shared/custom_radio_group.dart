import 'package:flutter/material.dart';
import 'package:bdcomputing/core/styles.dart';

class CustomRadioOption<T> {
  final T value;
  final String label;
  final String? subtitle;

  CustomRadioOption({
    required this.value,
    required this.label,
    this.subtitle,
  });
}

class CustomRadioGroup<T> extends StatelessWidget {
  final String? label;
  final T selectedValue;
  final List<CustomRadioOption<T>> options;
  final void Function(T) onChanged;
  final bool compact;

  const CustomRadioGroup({
    super.key,
    this.label,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.compact = false,
    this.isRequired = false,
  });

  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: const TextStyle(
                fontSize: 13,
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
          const SizedBox(height: 8),
        ],
        ...options.map((option) {
          final isSelected = option.value == selectedValue;
          return InkWell(
            onTap: () => onChanged(option.value),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: compact ? 4 : 8,
                horizontal: 4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: isSelected
                        ? Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (option.subtitle != null)
                          Text(
                            option.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
