import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const FullScreenLoader({
    super.key,
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.7),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withValues(alpha: 0.7),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: indicatorColor ?? Colors.green,
                    strokeWidth: 4,
                  ),
                ),
                if (title != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show the loader as an overlay
  static void show(
    BuildContext context, {
    String? title,
    String? subtitle,
    Color? backgroundColor,
    Color? indicatorColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => FullScreenLoader(
        title: title,
        subtitle: subtitle,
        backgroundColor: backgroundColor,
        indicatorColor: indicatorColor,
      ),
    );
  }

  /// Hide the loader overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
