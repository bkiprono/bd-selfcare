import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/components/shared/custom_button.dart';
import 'package:bdoneapp/components/shared/custom_text_field.dart';
import 'package:bdoneapp/core/routes.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdoneapp/components/shared/auth_background.dart';
import 'package:bdoneapp/screens/auth/auth_provider.dart';
import 'package:bdoneapp/screens/auth/domain/mfa_models.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GoogleConfirmationScreen extends ConsumerStatefulWidget {
  final String tempToken;
  final String email;

  const GoogleConfirmationScreen({
    super.key,
    required this.tempToken,
    required this.email,
  });

  @override
  ConsumerState<GoogleConfirmationScreen> createState() => _GoogleConfirmationScreenState();
}

class _GoogleConfirmationScreenState extends ConsumerState<GoogleConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    
    try {
      final result = await ref.read(authProvider.notifier).confirmGoogleLogin(
        tempToken: widget.tempToken,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      if (result is LoginSuccess) {
        Fluttertoast.showToast(msg: 'Account linked successfully!');
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
      } else {
        Fluttertoast.showToast(msg: 'Confirmation failed. Please check your password.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
                      'Link Google Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'An account with ${widget.email} already exists.\nPlease enter your password to link it with Google Sign-In.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Password Field
                    CustomTextField(
                      label: 'Account Password',
                      controller: _passwordCtrl,
                      hintText: 'Enter your password',
                      prefixIcon: HugeIcons.strokeRoundedLockPassword,
                      isRequired: true,
                      isPassword: true,
                      variant: 'filled',
                      showLabel: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    CustomButton(
                      text: 'Confirm & Link Account',
                      onPressed: _submit,
                      isLoading: _submitting,
                    ),
                    const SizedBox(height: 24),
                    
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
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
