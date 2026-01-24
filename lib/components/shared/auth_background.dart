import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bdoneapp/core/styles.dart';

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
                      AppColors.primary.withValues(alpha: 0.005),
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

  // Memoized Paint objects for performance
  final Paint _gridPaint = Paint()..strokeWidth = 0.3;
  final Paint _nodePaint = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()..strokeWidth = 0.2;
  final Paint _blobPaint = Paint();

  _AuthBackgroundPainter({
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw animated tech grid
    _drawGridPattern(canvas, size);

    // 2. Draw data flow lines (IT company aesthetic)
    _drawDataLines(canvas, size);

    // 3. Draw moving network nodes & connections
    _drawNetworkNodes(canvas, size);

    // 4. Draw ultra-subtle blobs
    _drawBlobs(canvas, size);
  }

  void _drawGridPattern(Canvas canvas, Size size) {
    _gridPaint.color = AppColors.primary300.withValues(alpha: 0.005);
    const spacing = 60.0;
    final gridTransition = animationValue * spacing;

    for (double x = -spacing + gridTransition; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _gridPaint);
    }

    for (double y = -spacing + gridTransition; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }
  }

  void _drawDataLines(Canvas canvas, Size size) {
    _linePaint.color = AppColors.primary300.withValues(alpha: 0.008);
    const lineSpacing = 120.0;
    
    for (int i = 0; i < 5; i++) {
        final double y = (i * lineSpacing + (animationValue * 50)) % size.height;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), _linePaint);
        
        // Draw a small "node" on the line
        final double x = (animationValue * size.width * (1 + i * 0.1)) % size.width;
        canvas.drawCircle(Offset(x, y), 1.5, _linePaint);
    }
  }

  void _drawNetworkNodes(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final p1 = particles[i];
      p1.update();
      
      final pos1 = Offset(p1.x * size.width, p1.y * size.height);
      
      // Draw node
      _nodePaint.color = p1.color.withValues(alpha: p1.opacity);
      canvas.drawCircle(pos1, p1.size, _nodePaint);

      // Draw faint connections between nearby nodes
      for (int j = i + 1; j < particles.length; j++) {
        final p2 = particles[j];
        final pos2 = Offset(p2.x * size.width, p2.y * size.height);
        
        final distance = (pos1 - pos2).distance;
        if (distance < 150) {
          final lineAlpha = (1 - (distance / 150)) * 0.02;
          _linePaint.color = p1.color.withValues(alpha: lineAlpha);
          canvas.drawLine(pos1, pos2, _linePaint);
        }
      }
    }
  }

  void _drawBlobs(Canvas canvas, Size size) {
    _blobPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Primary blob
    _drawBlob(canvas, size,
      offset: Offset(size.width * 0.2, size.height * 0.2),
      radius: 140,
      color: AppColors.primary300.withValues(alpha: 0.008),
      speed: 0.7,
      phase: 0,
    );

    // Secondary blob
    _drawBlob(canvas, size,
      offset: Offset(size.width * 0.8, size.height * 0.8),
      radius: 180,
      color: AppColors.secondary.withValues(alpha: 0.006),
      speed: 0.4,
      phase: math.pi,
    );
  }

  void _drawBlob(Canvas canvas, Size size, {
    required Offset offset,
    required double radius,
    required Color color,
    required double speed,
    required double phase,
  }) {
    _blobPaint.color = color;
    final angle = 2 * math.pi * animationValue * speed + phase;
    final dx = math.cos(angle) * 30;
    final dy = math.sin(angle) * 20;

    canvas.drawCircle(
      offset.translate(dx, dy),
      radius + math.sin(angle * 0.5) * 10,
      _blobPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuthBackgroundPainter oldDelegate) => true;
}
