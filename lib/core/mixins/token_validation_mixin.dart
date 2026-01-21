import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:bdcomputing/core/utils/jwt_helper.dart';
import 'package:bdcomputing/core/routes.dart';

/// Mixin that provides token validation functionality for screens
mixin TokenValidationMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Validates the current token and refreshes if needed
  Future<bool> validateToken() async {
    try {
      final repo = ref.read(authRepositoryProvider);

      // Show loading if we know we need a refresh (no token or expired)
      final token = await repo.getAccessToken();
      final needsRefresh =
          token == null || token.isEmpty || JwtHelper.isTokenExpired(token);
      if (needsRefresh) {
        _showLoadingDialog('Refreshing session...');
      }

      final ok = await repo.validateAndRefreshToken();

      if (needsRefresh && mounted) {
        Navigator.of(context).pop();
      }

      if (!ok) {
        _showTokenError('Session expired. Please log in again.');
        return false;
      }

      return true;
    } catch (e) {
      _showTokenError('Authentication error. Please try again.');
      return false;
    }
  }

  /// Validates token before performing an action
  Future<bool> validateTokenBeforeAction(VoidCallback action) async {
    final isValid = await validateToken();
    if (isValid && mounted) {
      action();
    }
    return isValid;
  }

  /// Shows a loading dialog with the given message
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Shows an error dialog for token-related issues
  void _showTokenError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  /// Shows a snackbar with token refresh feedback
  void showTokenRefreshFeedback(bool success) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Session refreshed successfully'
              : 'Failed to refresh session',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
