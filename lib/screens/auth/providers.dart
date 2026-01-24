import 'dart:async';
import 'package:bdoneapp/screens/auth/domain/auth_state.dart';
import 'package:bdoneapp/screens/auth/domain/password_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/core/utils/jwt_helper.dart';
import 'package:bdoneapp/components/logger_config.dart';
import 'package:bdoneapp/screens/auth/data/auth_repository.dart';
import 'package:bdoneapp/screens/auth/data/auth_service.dart';
import 'package:bdoneapp/screens/auth/domain/user_model.dart';
import 'package:bdoneapp/screens/auth/domain/mfa_models.dart';

final baseUrlProvider = Provider<String>((ref) => ApiEndpoints.baseUrl);

final unauthenticatedApiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return ApiClient(baseUrl: baseUrl);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(unauthenticatedApiClientProvider);
  return AuthService(apiClient: apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  late final AuthRepository repo;
  final apiClient = ApiClient(
    baseUrl: baseUrl,
    getAccessToken: () => repo.getAccessToken(),
    onRefreshToken: () => repo.refreshToken(),
  );
  repo = AuthRepository(
    service: ref.read(authServiceProvider),
    apiClient: apiClient,
  );
  return repo;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  Timer? _refreshTimer;

  AuthNotifier(this._repo) : super(const AuthLoading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final restored = await _repo.restoreSession();
      if (restored is Authenticated) {
        state = restored;
        _scheduleTokenRefresh();
      } else {
        state = restored;
      }
    } catch (e, s) {
      logger.e('Error during auth initialization', error: e, stackTrace: s);
      state = const Unauthenticated();
    }
  }

  Future<LoginResult> loginWithEmail(String email, String password) async {
    state = const AuthLoading();
    try {
      final result = await _repo.loginWithEmail(email, password);
      if (result is LoginSuccess) {
        state = Authenticated(User.fromJson(result.user));
        _scheduleTokenRefresh();
      } else {
        state = const Unauthenticated();
      }
      return result;
    } catch (e) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<LoginResult> loginWithPhone(String phone, String password) async {
    state = const AuthLoading();
    try {
      final result = await _repo.loginWithPhone(phone, password);
      if (result is LoginSuccess) {
        state = Authenticated(User.fromJson(result.user));
        _scheduleTokenRefresh();
      } else {
        state = const Unauthenticated();
      }
      return result;
    } catch (e) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      final response = await _repo.forgotPassword(email);
      state = const Unauthenticated();
      return response;
    } catch (e) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePassword(UpdatePasswordModel password) async {
    state = const AuthLoading();
    try {
      final response = await _repo.updatePassword(password);
      state = const Unauthenticated();
      return response;
    } catch (e) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<LoginResult> loginWithGoogle(String idToken) async {
    state = const AuthLoading();
    try {
      final result = await _repo.loginWithGoogle(idToken);
      if (result is LoginSuccess) {
        state = Authenticated(User.fromJson(result.user));
        _scheduleTokenRefresh();
      } else {
        state = const Unauthenticated();
      }
      return result;
    } catch (e) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<LoginResult> confirmGoogleLogin({
    required String tempToken,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _repo.confirmGoogleLogin(
        tempToken: tempToken,
        password: password,
      );
      if (result is LoginSuccess) {
        state = Authenticated(User.fromJson(result.user));
        _scheduleTokenRefresh();
      } else {
        state = const Unauthenticated();
      }
      return result;
    } catch (e) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _cancelRefreshTimer();
    state = const Unauthenticated();
  }

  Future<void> completeLogin({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await _repo.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );

    final userObj = User.fromJson(user);
    state = Authenticated(userObj);

    _scheduleTokenRefresh();
  }

  Future<LoginSuccess> verifyMfa({
    required String mfaToken,
    required String code,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _repo.service.verifyMfa(
        mfaToken: mfaToken,
        code: code,
      );

      await completeLogin(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user,
      );

      return result;
    } catch (e) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<void> toggleMfaMethod(MfaMethod method, bool enabled) async {
    state = const AuthLoading();
    try {
      final user = await _repo.toggleMfaMethod(method, enabled);
      state = Authenticated(user);
    } catch (e) {
      // Re-read current user to reset state if failed
      final user = await _repo.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
      rethrow;
    }
  }

  Future<void> disableTotp(String password) async {
    state = const AuthLoading();
    try {
      final user = await _repo.disableTotp(password);
      state = Authenticated(user);
    } catch (e) {
      final user = await _repo.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> startTotpSetup() async {
    return await _repo.startTotpSetup();
  }

  Future<Map<String, dynamic>> completeTotpSetup(String setupToken, String verificationCode) async {
    state = const AuthLoading();
    try {
      final res = await _repo.completeTotpSetup(setupToken, verificationCode);
      final user = await _repo.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
      return res;
    } catch (e) {
       final user = await _repo.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _repo.refreshProfile();
      state = Authenticated(user);
    } catch (e) {
      // If refresh profile fails, we don't necessarily want to logout
      // but we should log it.
      logger.e('Error refreshing profile', error: e);
      rethrow;
    }
  }

  Future<User?> getCurrentUser() => _repo.getCurrentUser();

  void _scheduleTokenRefresh() {
    _cancelRefreshTimer();
    // Decode JWT exp and schedule refresh 60 seconds before expiry.
    () async {
      final token = await _repo.getAccessToken();
      if (token == null || token.isEmpty) {
        // No token available, logout
        await logout();
        return;
      }

      // Use JwtHelper for more robust token validation
      if (JwtHelper.isTokenExpired(token)) {
        // Token is already expired, try to refresh immediately
        bool ok = await _repo.refreshToken();
        
        // Retry logic for transient failures
        int retries = 0;
        while (!ok && retries < 3) {
          retries++;
          logger.i('Token refresh failed, retrying ($retries/3)...');
          await Future.delayed(Duration(seconds: 2 * retries));
          ok = await _repo.refreshToken();
        }

        if (!ok) {
          await logout();
        } else {
          _scheduleTokenRefresh(); // Schedule next refresh
        }
        return;
      }

      try {
        final expiryDate = JwtHelper.getTokenExpiryDate(token);
        if (expiryDate == null) {
          // Cannot determine expiry, use fallback
          _scheduleFallbackRefresh();
          return;
        }

        final now = DateTime.now();
        final timeUntilExpiry = expiryDate.difference(now);
        final refreshTime = timeUntilExpiry - const Duration(seconds: 60);

        if (refreshTime.isNegative) {
          // Token expires soon, refresh immediately
          bool ok = await _repo.refreshToken();
          
          // Retry logic for transient failures
          int retries = 0;
          while (!ok && retries < 3) {
            retries++;
            logger.i('Token refresh failed, retrying ($retries/3)...');
            await Future.delayed(Duration(seconds: 2 * retries));
            ok = await _repo.refreshToken();
          }

          if (!ok) {
            await logout();
          } else {
            _scheduleTokenRefresh();
          }
        } else {
          // Schedule refresh 60 seconds before expiry
          _refreshTimer = Timer(refreshTime, () async {
            bool ok = await _repo.refreshToken();
            
            // Retry logic for transient failures
            int retries = 0;
            while (!ok && retries < 3) {
              retries++;
              logger.i('Token refresh failed (scheduled), retrying ($retries/3)...');
              await Future.delayed(Duration(seconds: 2 * retries));
              ok = await _repo.refreshToken();
            }

            if (!ok) {
              await logout();
            } else {
              _scheduleTokenRefresh();
            }
          });
        }
      } catch (e, s) {
        logger.e('Error scheduling token refresh', error: e, stackTrace: s);
        _scheduleFallbackRefresh();
      }
    }();
  }

  void _scheduleFallbackRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      final token = await _repo.getAccessToken();
      if (token != null && JwtHelper.isTokenExpired(token)) {
        final ok = await _repo.refreshToken();
        if (!ok) {
          await logout();
        }
      }
    });
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

// Onboarding state management (persist simple seen flag)
class OnboardingController extends StateNotifier<bool> {
  OnboardingController() : super(false) {
    _load();
  }

  static const _key = 'onboarding_complete';

  Future<void> _load() async {
    // Using SharedPreferences here is fine since it's non-sensitive UI state
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingController, bool>((
  ref,
) {
  return OnboardingController();
});
