import 'package:bdoneapp/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum CustomButtonStyle { primary, outlined, ghost }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final dynamic icon;
  final CustomButtonStyle style;
  final Color? color;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.style = CustomButtonStyle.primary,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    Widget content = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            _buildIcon(icon, style == CustomButtonStyle.primary ? Colors.white : effectiveColor),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    switch (style) {
      case CustomButtonStyle.outlined:
        return SizedBox(
          width: width ?? double.infinity,
          child: OutlinedButton(
            onPressed: isEnabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveColor,
              side: BorderSide(color: effectiveColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: content,
          ),
        );
      case CustomButtonStyle.ghost:
        return SizedBox(
          width: width ?? double.infinity,
          child: TextButton(
            onPressed: isEnabled ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: effectiveColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: content,
          ),
        );
      case CustomButtonStyle.primary:
      return SizedBox(
          width: width ?? double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: content,
          ),
        );
    }
  }

  Widget _buildIcon(dynamic icon, Color color) {
    if (icon is IconData) {
      return Icon(
        icon,
        color: color,
        size: 18,
      );
    }
    return HugeIcon(
      icon: icon,
      color: color,
      size: 18,
    );
  }
}
