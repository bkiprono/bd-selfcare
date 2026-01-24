import 'package:bdoneapp/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/screens/auth/domain/auth_state.dart';
import 'package:bdoneapp/screens/auth/presentation/auth_switch.dart';
import 'package:bdoneapp/screens/auth/providers.dart';
import 'package:bdoneapp/core/routes.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);

    if (state is AuthLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    if (state is Authenticated) {
      // Validate token before allowing access
      return _TokenValidator(child: child);
    }

    return const AuthSwitchScreen();
  }
}

class _TokenValidator extends ConsumerStatefulWidget {
  final Widget child;
  const _TokenValidator({required this.child});

  @override
  ConsumerState<_TokenValidator> createState() => _TokenValidatorState();
}

class _TokenValidatorState extends ConsumerState<_TokenValidator> {
  bool _isValidating = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  Future<void> _validateToken() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final token = await authNotifier.getCurrentUser();

      if (token == null) {
        setState(() {
          _isValidating = false;
          _errorMessage = 'No user session found';
        });
        return;
      }

      // Check if we need to validate and refresh token
      final repo = ref.read(authRepositoryProvider);
      final isValid = await repo.validateAndRefreshToken();

      if (!isValid) {
        setState(() {
          _isValidating = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
        // Trigger logout after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            ref.read(authProvider.notifier).logout();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
          }
        });
        return;
      }

      setState(() {
        _isValidating = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isValidating = false;
        _errorMessage = 'Authentication error. Please log in again.';
      });
      // Trigger logout after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          ref.read(authProvider.notifier).logout();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text('Validating session...', style: TextStyle(color: Colors.white),),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
