import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/core/styles.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final dynamic leadingIcon;
  final dynamic trailingIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  Widget _buildIcon(dynamic icon, Color color) {
    if (icon is IconData) {
      return Icon(
        icon,
        color: color,
        size: 20,
      );
    } else {
      // Assume it's a HugeIconData
      return HugeIcon(
        icon: icon,
        color: color,
        size: 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled = isDisabled || isLoading || onPressed == null;
    final Color bgColor = backgroundColor ?? AppColors.primary;
    final Color fgColor = textColor ?? AppColors.textOnPrimary;

    return SizedBox(
      width: width ?? double.infinity,
      child: CupertinoButton(
        onPressed: effectivelyDisabled ? null : onPressed,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: effectivelyDisabled ? CupertinoColors.systemGrey4 : bgColor,
        disabledColor: CupertinoColors.systemGrey4,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CupertinoActivityIndicator(
                  color: fgColor,
                ),
              )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[
                      _buildIcon(leadingIcon, fgColor),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: fgColor,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _buildIcon(trailingIcon, fgColor),
                    ],
                  ],
                ),
            ),
      ),
    );
  }
}
