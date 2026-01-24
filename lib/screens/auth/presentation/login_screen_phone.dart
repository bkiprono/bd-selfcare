import 'package:bdoneapp/core/navigation/adaptive_page_route.dart';
import 'package:flutter/material.dart';
import 'package:bdoneapp/core/routes.dart';
import 'package:bdoneapp/screens/auth/presentation/signup_screen.dart';
import 'package:bdoneapp/screens/auth/presentation/login_screen_email.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/screens/auth/auth_provider.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/components/shared/custom_text_field.dart';
import 'package:bdoneapp/components/shared/custom_button.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdoneapp/screens/auth/domain/mfa_models.dart';
import 'package:bdoneapp/components/shared/auth_background.dart';

class LoginWithPhoneScreen extends ConsumerStatefulWidget {
  const LoginWithPhoneScreen({super.key});

  @override
  ConsumerState<LoginWithPhoneScreen> createState() =>
      _LoginWithPhoneScreenState();
}

class _LoginWithPhoneScreenState extends ConsumerState<LoginWithPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final result = await ref
          .read(authProvider.notifier)
          .loginWithPhone(_phoneCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) {
        if (result is MfaRequired) {
          Navigator.of(context).pushNamed(
            AppRoutes.mfaVerification,
            arguments: {
              'mfaToken': result.mfaToken,
              'methods': result.mfaMethods,
              'target': _phoneCtrl.text.trim(),
            },
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isLoading = _submitting || state is AuthLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo/Icon
                    Center(
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Image(
                          image: AssetImage('assets/images/brand/dark.png'),
                        ),
                      ),
                    ),
                  ),
                    const SizedBox(height: 32),
                    
                    // Title
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    const Text(
                      'To sign in to an account in the application,\nenter your phone and password',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
  
                    // Phone Field
                    CustomTextField(
                      label: 'Phone',
                      controller: _phoneCtrl,
                      hintText: 'e.g., 0719155083',
                      prefixIcon: HugeIcons.strokeRoundedSmartPhone01,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      variant: 'filled',
                      showLabel: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
  
                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      controller: _passwordCtrl,
                      hintText: 'Password',
                      prefixIcon: HugeIcons.strokeRoundedLockPassword,
                      isRequired: true,
                      isPassword: true,
                      variant: 'filled',
                      showLabel: true,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : null,
                    ),
                    const SizedBox(height: 24),
  
                    // Continue Button
                    CustomButton(
                      text: 'Continue',
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 24),
  
                    // Switch to Email Login
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).pushReplacement(
                                  AdaptivePageRoute(
                                    builder: (_) => const LoginWithEmailScreen(),
                                  ),
                                );
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Sign in with Email instead',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
  
                    // Don't have an account
                    const Center(
                      child: Text(
                        'Don\'t have an account yet?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
  
                    // Create Account Button
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  AdaptivePageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
  
                    // Sign in with Apple
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedApple,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                        label: const Text(
                          'Sign in with Apple',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
  
                    // Sign in with Google
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedGoogle,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
  
                    // Terms and Privacy
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'By clicking "Continue", I have read and agree\nwith the ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Term Sheet',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(text: ', '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
