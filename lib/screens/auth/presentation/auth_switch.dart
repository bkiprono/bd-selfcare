import 'package:flutter/material.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';

class AuthSwitchScreen extends StatelessWidget {
  const AuthSwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[200]!, Colors.grey[100]!, Colors.white],
              ),
            ),
            child: CustomPaint(
              painter: CircularPatternPainter(),
              size: Size.infinite,
            ),
          ),
          _buildFloatingElements(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        Positioned(
          top: 280,
          left: 0,
          right: 0,
          child: Center(
            child: Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: 60,
          child: _buildFloatingAvatar(Icons.location_on, Colors.purple, 40),
        ),
        Positioned(
          top: 140,
          left: 0,
          right: 0,
          child: Center(child: _buildAvatarCircle(Colors.yellow, '⛽')),
        ),
        Positioned(
          top: 180,
          right: 60,
          child: _buildFloatingAvatar(
            Icons.notifications_active,
            Colors.purple,
            40,
          ),
        ),
        Positioned(
          top: 260,
          left: 80,
          child: Transform.rotate(
            angle: -0.5,
            child: Icon(
              Icons.campaign,
              size: 50,
              color: Colors.purple.withValues(alpha: 0.8),
            ),
          ),
        ),
        Positioned(
          top: 320,
          left: 50,
          child: _buildAvatarCircle(Colors.green, '👨🏻'),
        ),
        Positioned(
          top: 280,
          right: 50,
          child: _buildAvatarCircle(Colors.purple, '👩🏿'),
        ),
        Positioned(
          top: 380,
          right: 40,
          child: _buildAvatarCircle(Colors.pink, '👩🏽'),
        ),
      ],
    );
  }

  Widget _buildAvatarCircle(Color color, String emoji) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }

  Widget _buildFloatingAvatar(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.auto_awesome, size: 28, color: Colors.grey[800]),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Order petroleum products and equipment\nquickly and securely with Pedea Shopping.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Continue with Email',
              style: CustomButtonStyle.outlined,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.loginWithEmail);
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Continue with Phone',
              style: CustomButtonStyle.outlined,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.loginWithPhone);
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Register as Partner',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.register);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class CircularPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.grey.withValues(alpha: 0.15);

    final center = Offset(size.width / 2, size.height * 0.35);

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, i * 50.0, paint);
    }

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final x = center.dx + (250 * (i % 2 == 0 ? 1 : 0.7)) * cos(angle);
      final y = center.dy + (250 * (i % 2 == 0 ? 1 : 0.7)) * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  double cos(double angle) => (angle == 0)
      ? 1
      : (angle == 1.5708)
          ? 0
          : (angle == 3.14159)
              ? -1
              : (angle == 4.71239)
                  ? 0
                  : angle < 1.5708
                      ? 1 - (angle * angle / 2)
                      : angle < 3.14159
                          ? -(1 - ((angle - 1.5708) * (angle - 1.5708) / 2))
                          : angle < 4.71239
                              ? -1 + ((angle - 3.14159) * (angle - 3.14159) / 2)
                              : 1 - ((angle - 4.71239) * (angle - 4.71239) / 2);

  double sin(double angle) => cos(angle - 1.5708);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
