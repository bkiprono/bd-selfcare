import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bdcomputing/core/styles.dart';

class AuthBackground extends StatefulWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base white background
        Positioned.fill(
          child: Container(color: Colors.white),
        ),
        
        // Animated background elements
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _AuthBackgroundPainter(
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        ),
        
        // Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  final double animationValue;

  _AuthBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBlob(
      canvas,
      size,
      offset: Offset(size.width * 0.1, size.height * 0.1),
      radius: 150,
      color: AppColors.primary.withValues(alpha: 0.03),
      shift: 20,
      phase: 0,
    );

    _drawBlob(
      canvas,
      size,
      offset: Offset(size.width * 0.9, size.height * 0.8),
      radius: 200,
      color: AppColors.primary.withValues(alpha: 0.04),
      shift: 30,
      phase: math.pi,
    );

    _drawBlob(
      canvas,
      size,
      offset: Offset(size.width * 0.5, size.height * 0.4),
      radius: 100,
      color: AppColors.primary.withValues(alpha: 0.02),
      shift: 15,
      phase: math.pi / 2,
    );
  }

  void _drawBlob(
    Canvas canvas,
    Size size, {
    required Offset offset,
    required double radius,
    required Color color,
    required double shift,
    required double phase,
  }) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final angle = 2 * math.pi * animationValue + phase;
    final dx = math.cos(angle) * shift;
    final dy = math.sin(angle) * shift;

    canvas.drawCircle(
      offset.translate(dx, dy),
      radius + math.sin(angle) * 10,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuthBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
