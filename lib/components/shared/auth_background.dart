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
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    const int _particleCount = 12;
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle());
    }
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
        // Base animated gradient background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppColors.primary300.withValues(alpha: 0.005),
                      AppColors.secondary.withValues(alpha: 0.005),
                      AppColors.accent.withValues(alpha: 0.005),
                      Colors.white,
                    ],
                    stops: [
                      0.0,
                      (math.sin(2 * math.pi * _controller.value) + 1) / 3,
                      (math.sin(2 * math.pi * _controller.value + math.pi / 2) + 1) / 2,
                      (math.cos(2 * math.pi * _controller.value) + 1) / 1.5,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Animated patterns and particles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _AuthBackgroundPainter(
                  animationValue: _controller.value,
                  particles: _particles,
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

class _Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late double opacity;
  late Color color;

  _Particle() {
    _reset();
  }

  void _reset() {
    final rand = math.Random();
    x = rand.nextDouble();
    y = rand.nextDouble();
    vx = (rand.nextDouble() - 0.5) * 0.0008;
    vy = (rand.nextDouble() - 0.5) * 0.0008;
    size = rand.nextDouble() * 2 + 1;
    opacity = rand.nextDouble() * 0.05 + 0.01;
    
    // Assign random theme color
    final colorRand = rand.nextInt(3);
    if (colorRand == 0) {
      color = AppColors.primary300;
    } else if (colorRand == 1) {
      color = AppColors.secondary;
    } else {
      color = AppColors.accent;
    }
  }

  void update() {
    x += vx;
    y += vy;

    if (x < 0 || x > 1) vx *= -1;
    if (y < 0 || y > 1) vy *= -1;
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  final double animationValue;
  final List<_Particle> particles;

  _AuthBackgroundPainter({
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw animated subtle grid/dots
    _drawGridPattern(canvas, size);

    // 2. Draw moving particles
    _drawParticles(canvas, size);

    // 3. Draw animated blobs with primary, secondary and accent colors
    _drawBlobs(canvas, size);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.update();
      paint.color = particle.color.withValues(alpha: particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  void _drawBlobs(Canvas canvas, Size size) {
    // Primary blob
    _drawBlob(
      canvas,
      size,
      offset: Offset(size.width * 0.15, size.height * 0.15),
      radius: 180,
      color: AppColors.primary300.withValues(alpha: 0.03), // Reduced opacity
      shift: 40,
      phase: 0,
      speedMultiplier: 1.2,
    );

    // Secondary blob
    _drawBlob(
      canvas,
      size,
      offset: Offset(size.width * 0.85, size.height * 0.85),
      radius: 240,
      color: AppColors.secondary.withValues(alpha: 0.01), // Reduced opacity
      shift: 60,
      phase: math.pi,
      speedMultiplier: 0.8,
    );

    // Accent blob
    _drawBlob(
      canvas,
      size,
      offset: Offset(size.width * 0.7, size.height * 0.2),
      radius: 120,
      color: AppColors.accent.withValues(alpha: 0.005), // Reduced opacity
      shift: 25,
      phase: math.pi / 3,
      speedMultiplier: 1.5,
    );

    // Additional Primary blob at bottom-left
    _drawBlob(
      canvas,
      size,
      offset: Offset(size.width * 0.2, size.height * 0.8),
      radius: 150,
      color: AppColors.primary300.withValues(alpha: 0.02), // Reduced opacity
      shift: 35,
      phase: 4 * math.pi / 3,
      speedMultiplier: 1.1,
    );
  }

  void _drawGridPattern(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary300.withValues(alpha: 0.01) // Reduced opacity
      ..strokeWidth = 0.5; // Reduced stroke width

    const spacing = 50.0;
    final gridTransition = animationValue * spacing;

    for (double x = -spacing + gridTransition; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = -spacing + gridTransition; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawBlob(
    Canvas canvas,
    Size size, {
    required Offset offset,
    required double radius,
    required Color color,
    required double shift,
    required double phase,
    double speedMultiplier = 1.0,
  }) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final angle = 2 * math.pi * animationValue * speedMultiplier + phase;
    final dx = math.cos(angle) * shift + math.sin(angle * 0.5) * (shift / 2);
    final dy = math.sin(angle) * shift + math.cos(angle * 0.7) * (shift / 2);

    canvas.drawCircle(
      offset.translate(dx, dy),
      radius + math.sin(angle * 0.8) * 25,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuthBackgroundPainter oldDelegate) => true;
}
