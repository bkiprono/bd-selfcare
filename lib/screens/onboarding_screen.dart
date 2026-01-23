import 'package:bdcomputing/core/styles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/screens/auth/auth_provider.dart';
import 'package:bdcomputing/core/routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatController;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      topLabel: 'DISCOVER VR',
      title: 'Stay ahead\nof the tech curve',
      illustration: 'assets/onboarding1.png',
      gradientColors: [
        const Color(0xFF4ADE80),
        const Color(0xFF22D3EE),
      ],
      iconData: Icons.videogame_asset_outlined,
    ),
    OnboardingPage(
      topLabel: 'CUSTOMER APPROACH',
      title: 'Much more than\nlive chat',
      illustration: 'assets/onboarding2.png',
      gradientColors: [
        const Color(0xFFFBBF24),
        const Color(0xFF84CC16),
      ],
      iconData: Icons.chat_bubble_outline,
    ),
    OnboardingPage(
      topLabel: 'LATEST UPDATES',
      title: 'Spotlight\nnew features',
      illustration: 'assets/onboarding3.png',
      gradientColors: [
        const Color(0xFFF472B6),
        const Color(0xFFFB923C),
      ],
      iconData: Icons.auto_awesome_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _fadeController.reset();
    _fadeController.forward();
    _scaleController.reset();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Background Art
          AnimatedBackgroundArt(
            currentPage: _currentPage,
            gradientColors: _pages[_currentPage].gradientColors,
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar with fade in animation
                FadeTransition(
                  opacity: _fadeController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo with scale animation
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/brand/dark.png',
                            height: 28,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                        ),
                        // Skip button with hover effect
                        _AnimatedSkipButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _pages.length - 1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPageWidget(
                        page: _pages[index],
                        fadeController: _fadeController,
                        scaleController: _scaleController,
                        floatController: _floatController,
                      );
                    },
                  ),
                ),

                // Bottom Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Page Indicators with stagger animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _AnimatedPageIndicator(
                            isActive: _currentPage == index,
                            delay: index * 100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Next/Get Started Button with bounce animation
                      _AnimatedButton(
                        currentPage: _currentPage,
                        totalPages: _pages.length,
                        onPressed: () async {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // Mark onboarding as complete
                            await ref.read(onboardingProvider.notifier).complete();
                            
                            // Navigate to login screen
                            if (mounted) {
                              Navigator.of(context).pushReplacementNamed(
                                AppRoutes.home,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackgroundArt extends StatelessWidget {
  final int currentPage;
  final List<Color> gradientColors;

  const AnimatedBackgroundArt({
    super.key,
    required this.currentPage,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Stack(
        children: [
          // Top right blob
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    gradientColors[0].withOpacity(0.1),
                    gradientColors[0].withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom left blob
          Positioned(
            bottom: -50,
            left: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    gradientColors[1].withOpacity(0.15),
                    gradientColors[1].withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Floating particles
          ...List.generate(5, (index) {
            return Positioned(
              top: 100.0 + (index * 120),
              left: 30.0 + (index * 70) % 300,
              child: _FloatingParticle(
                delay: index * 200,
                color: gradientColors[index % 2].withOpacity(0.1),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FloatingParticle extends StatefulWidget {
  final int delay;
  final Color color;

  const _FloatingParticle({required this.delay, required this.color});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + widget.delay),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_controller.value * 2 * math.pi) * 20),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final AnimationController fadeController;
  final AnimationController scaleController;
  final AnimationController floatController;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.fadeController,
    required this.scaleController,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Label with slide animation
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: fadeController,
              curve: Curves.easeOut,
            )),
            child: FadeTransition(
              opacity: fadeController,
              child: Text(
                page.topLabel,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title with scale animation
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: scaleController,
                curve: Curves.easeOutBack,
              ),
            ),
            child: FadeTransition(
              opacity: fadeController,
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),

          // Illustration with gradient background and float animation
          AnimatedBuilder(
            animation: floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(floatController.value * 2 * math.pi) * 10),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: scaleController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gradient background blob with pulse animation
                      AnimatedBuilder(
                        animation: floatController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (math.sin(floatController.value * 2 * math.pi) * 0.05),
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: page.gradientColors
                                      .map((c) => c.withOpacity(0.3))
                                      .toList(),
                                ),
                                borderRadius: BorderRadius.circular(150),
                              ),
                            ),
                          );
                        },
                      ),
                      // Icon illustration with rotation
                      AnimatedBuilder(
                        animation: floatController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: math.sin(floatController.value * 2 * math.pi) * 0.05,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: page.gradientColors[0].withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                page.iconData,
                                size: 100,
                                color: page.gradientColors[0],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedPageIndicator extends StatefulWidget {
  final bool isActive;
  final int delay;

  const _AnimatedPageIndicator({
    required this.isActive,
    required this.delay,
  });

  @override
  State<_AnimatedPageIndicator> createState() => _AnimatedPageIndicatorState();
}

class _AnimatedPageIndicatorState extends State<_AnimatedPageIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_AnimatedPageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: widget.isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: widget.isActive ? AppColors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _AnimatedSkipButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedSkipButton({required this.onPressed});

  @override
  State<_AnimatedSkipButton> createState() => _AnimatedSkipButtonState();
}

class _AnimatedSkipButtonState extends State<_AnimatedSkipButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _isHovered ? Colors.grey[600] : Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            child: const Text('Skip'),
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.currentPage,
    required this.totalPages,
    required this.onPressed,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  widget.currentPage == widget.totalPages - 1
                      ? 'Get Started'
                      : 'Next',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OnboardingPage {
  final String topLabel;
  final String title;
  final String illustration;
  final List<Color> gradientColors;
  final IconData iconData;

  OnboardingPage({
    required this.topLabel,
    required this.title,
    required this.illustration,
    required this.gradientColors,
    required this.iconData,
  });
}