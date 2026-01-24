import 'package:bdcomputing/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final Widget? suffixIcon;
  final dynamic prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final void Function(String)? onChanged;
  final String? prefixText;
  final bool isRequired;
  final String variant; // 'outlined' or 'filled'
  final bool showLabel; // Whether to show label above field

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.validator,
    this.isPassword = false,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.onChanged,
    this.prefixText,
    this.isRequired = false,
    this.variant = 'outlined',
    this.showLabel = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isFilled = widget.variant == 'filled';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
                children: [
                  if (widget.isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                ],
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixText: widget.prefixText,
            prefixStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isFilled ? 16 : 16,
              vertical: isFilled ? 16 : 12,
            ),
            filled: true,
            fillColor: isFilled ? const Color(0xFFF5F5F5) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isFilled ? 12 : AppRadius.md),
              borderSide: isFilled
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isFilled ? 12 : AppRadius.md),
              borderSide: isFilled
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isFilled ? 12 : AppRadius.md),
              borderSide: isFilled
                  ? const BorderSide(color: AppColors.primary, width: 1.5)
                  : const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isFilled ? 12 : AppRadius.md),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: isFilled ? AppColors.primary : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildIcon(
                      widget.prefixIcon,
                      AppColors.primary,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(dynamic icon, Color color) {
    if (icon is IconData) {
      return Icon(
        icon,
        color: color,
        size: 20,
      );
    }
    // If it's from HugeIcons, it's typically a List<List<dynamic>> or HugeIconData
    return HugeIcon(
      icon: icon,
      color: color,
      size: 20,
    );
  }
}
