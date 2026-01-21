import 'package:flutter/material.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Manage Orders Seamlessly',
      'subtitle':
          'Accept and fulfill fuel orders from customers in real-time with our vendor dashboard.',
      'image': 'assets/images/onboarding/onboarding-1.png',
    },
    {
      'title': 'Track Deliveries in Real-Time',
      'subtitle':
          'Monitor your delivery fleet and ensure timely fulfillment of petroleum orders.',
      'image': 'assets/images/onboarding/onboarding-2.jpg',
    },
    {
      'title': 'Grow Your Fuel Business',
      'subtitle':
          'Reach more customers and expand your petroleum distribution with Pedea.',
      'image': 'assets/images/onboarding/onboarding-3.jpg',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and language selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/brand/dark.png',
                          height: 26,
                          // width: 36,
                        ),
                      ],
                    ),
                  ),
                  // Language selector
                  TextButton(
                    onPressed: () {
                      _completeOnboarding();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                  ),
                ],
              ),
            ),

            // Image section
            Expanded(
              flex: 55,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: Center(
                      child: Image.asset(
                        page['image']!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.local_gas_station_rounded,
                            color: Colors.grey[400],
                            size: 120,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom section with text and button
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  20,
                  32,
                  8,
                ), // decreased bottom padding for space for footer
                child: Column(
                  children: [
                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _pages[_pageIndex]['title']!,
                        key: ValueKey<int>(_pageIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _pages[_pageIndex]['subtitle']!,
                        key: ValueKey<int>(_pageIndex + 100),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _pageIndex == i ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _pageIndex == i
                                ? AppColors.primary
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Log in button
                    CustomButton(
                      text: _pageIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                      onPressed: _pageIndex == _pages.length - 1
                          ? _completeOnboarding
                          : () => _controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              ),
                    ),

                    const SizedBox(height: 16),

                    // Sign up text
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.register);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            children: [
                              const TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Powered by BD Computing Limited
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 2),
              child: Center(
                child: Text(
                  'Powered by BD Computing Limited',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
