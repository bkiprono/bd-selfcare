import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/components/shared/auth_background.dart';
import 'package:bdcomputing/screens/auth/auth_provider.dart';
import 'package:bdcomputing/screens/auth/domain/mfa_models.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthSwitchScreen extends ConsumerWidget {
  const AuthSwitchScreen({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
      );
      
      final account = await googleSignIn.signIn();
      if (account == null) return; // User cancelled

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        Fluttertoast.showToast(msg: 'Failed to get Google ID Token');
        return;
      }

      final result = await ref.read(authProvider.notifier).loginWithGoogle(idToken);

      if (result is LoginSuccess) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
      } else if (result is LoginAccepted) {
        // Confirmation required (account exists but not linked)
        Navigator.of(context).pushNamed(
          AppRoutes.googleConfirm,
          arguments: {
            'tempToken': result.tempToken,
            'email': result.email,
          },
        );
      } else if (result is MfaRequired) {
        // MFA required
        Navigator.of(context).pushNamed(
          AppRoutes.mfaVerification,
          arguments: {
            'mfaToken': result.mfaToken,
            'methods': result.mfaMethods,
          },
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Google Sign-In failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    'Get Started',
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
                    'Choose your preferred way to access\nthe BD Work OS application',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
  
                  // Register Button (Primary Action)
                  CustomButton(
                    text: 'Create an account',
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.register);
                    },
                  ),
                  const SizedBox(height: 24),
  
                  // Social/Alternative options separator
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // login with google
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleGoogleSignIn(context, ref),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
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
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
  
                  // login with email
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.loginWithEmail);
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
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedMail01,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'Continue with Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
  
                  // login with phone
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.loginWithPhone);
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
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedPhoneErase,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'Continue with Phone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
    );
  }
}
