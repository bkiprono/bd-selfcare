import 'dart:convert';
import 'package:bdcomputing/screens/auth/domain/mfa_models.dart';
import 'package:logger/logger.dart';
import 'package:bdcomputing/screens/auth/domain/auth_state.dart';
import 'package:bdcomputing/screens/auth/domain/password_model.dart';
import 'package:bdcomputing/screens/auth/domain/user_model.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/utils/jwt_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bdcomputing/screens/auth/data/auth_service.dart';

class AuthRepository {
  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyUser = 'user';
  final _logger = Logger();

  final AuthService _service;
  final ApiClient _apiClient;

  AuthRepository({required AuthService service, required ApiClient apiClient})
    : _service = service,
      _apiClient = apiClient;

  AuthService get service => _service;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<AuthState> restoreSession() async {
    try {
      final accessToken = await _secureStorage.read(key: _keyAccessToken);
      final refreshToken = await _secureStorage.read(key: _keyRefreshToken);
      final userJson = await _secureStorage.read(key: _keyUser);

      if (accessToken == null || refreshToken == null || userJson == null) {
        _logger.i('No stored session found');
        return const Unauthenticated();
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = User.fromJson(userMap);

      // Validate access token
      if (JwtHelper.isTokenExpired(accessToken)) {
        _logger.i('Access token expired, attempting to refresh...');
        // Token is expired, try to refresh
        final refreshed = await this.refreshToken();
        if (!refreshed) {
          _logger.i('Session restoration failed: Refresh token expired or invalid');
          // Refresh failed, clear session
          await logout();
          return const Unauthenticated();
        }
      }

      return Authenticated(user);
    } catch (e, s) {
      _logger.e('Error restoring session', error: e, stackTrace: s);
      await logout();
      return const Unauthenticated();
    }
  }

  Future<LoginResult> loginWithEmail(String email, String password) async {
    final result = await _service.loginWithEmail(
      email: email,
      password: password,
    );

    if (result is LoginSuccess) {
      await _handleLoginSuccess(result);
    }
    
    return result;
  }

  Future<LoginResult> loginWithPhone(String phone, String password) async {
    final result = await _service.loginWithPhone(
      phone: phone,
      password: password,
    );

    if (result is LoginSuccess) {
      await _handleLoginSuccess(result);
    }
    
    return result;
  }

  Future<LoginResult> loginWithGoogle(String idToken) async {
    final result = await _service.loginWithGoogle(idToken);

    if (result is LoginSuccess) {
      await _handleLoginSuccess(result);
    }
    
    return result;
  }

  Future<LoginResult> confirmGoogleLogin({
    required String tempToken,
    required String password,
  }) async {
    final result = await _service.confirmGoogleLogin(
      tempToken: tempToken,
      password: password,
    );

    if (result is LoginSuccess) {
      await _handleLoginSuccess(result);
    }
    
    return result;
  }

  Future<void> _handleLoginSuccess(LoginSuccess result) async {
    var userJson = result.user;
    var user = User.fromJson(userJson);

    // Ensure we have full client data including country
    user = await _ensureClientData(user, userJson);

    await saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      user: user.toJson(),
    );
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await _saveSession(accessToken, refreshToken, user);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _service.forgotPassword(email);
  }

  Future<Map<String, dynamic>> updatePassword(
    UpdatePasswordModel password,
  ) async {
    return await _service.updatePassword(password);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyUser);
  }

  Future<bool> refreshToken() async {
    final currentRefresh = await _secureStorage.read(key: _keyRefreshToken);
    if (currentRefresh == null || currentRefresh.isEmpty) {
      _logger.i('No refresh token available');
      return false;
    }

    try {
      // Validate refresh token before calling API
      if (JwtHelper.isTokenExpired(currentRefresh)) {
        _logger.i('Refresh token expired');
        await logout();
        return false;
      }

      final masked = currentRefresh.length > 10
          ? '${currentRefresh.substring(0, 5)}...${currentRefresh.substring(currentRefresh.length - 5)}'
          : '***masked***';
      _logger.i('Attempting token refresh with refresh_token: $masked');

      final refreshed = await _service.refreshToken(currentRefresh);
      final access = refreshed.accessToken;
      final refresh = refreshed.refreshToken;

      // Validate new tokens
      if (access.isEmpty || refresh.isEmpty) {
        _logger.i('Invalid tokens received from refresh');
        await logout();
        return false;
      }

      // Check if new access token is valid
      if (JwtHelper.isTokenExpired(access)) {
        _logger.i('New access token is already expired');
        await logout();
        return false;
      }

      await _secureStorage.write(key: _keyAccessToken, value: access);
      await _secureStorage.write(key: _keyRefreshToken, value: refresh);
      _logger.i('Token refreshed successfully');
      return true;
    } catch (e) {
      _logger.i('Token refresh failed: $e');
      await logout();
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _keyAccessToken);
  }

  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: _keyUser);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Validates the current access token and refreshes if needed
  Future<bool> validateAndRefreshToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      _logger.i('Access token missing; trying refresh with refresh token');
      return await refreshToken();
    }

    if (JwtHelper.isTokenExpired(token)) {
      _logger.i('Access token expired; trying refresh with refresh token');
      return await refreshToken();
    }
    return true;
  }

  Future<User> refreshProfile() async {
    final res = await _apiClient.get(ApiEndpoints.getProfile);
    final root = res.data as Map<String, dynamic>;
    final responsePayload = (root['data'] ?? root) as Map<String, dynamic>;

    final userBody = responsePayload['user'] as Map<String, dynamic>;

    // Include client data if present in the response
    if (responsePayload['client'] != null) {
      userBody['client'] = responsePayload['client'];
    }

    var user = User.fromJson(userBody);

    // Ensure we have full client data including country
    user = await _ensureClientData(user, userBody);

    await _saveUser(user.toJson());

    return user;
  }

  // Ensure user has complete client data (fetched if necessary)
  Future<User> _ensureClientData(
    User user,
    Map<String, dynamic> userJson,
  ) async {
    // If we have a clientId but no client object, or if some critical client fields are missing,
    // we fetch the full profile to ensure all data is present.
    if (user.clientId != null && (user.client == null || user.client!.name.isEmpty)) {
      _logger.i('Client data incomplete for ${user.email}, fetching full profile...');
      try {
        return await refreshProfile();
      } catch (e) {
        _logger.w('Failed to enrich client data: $e');
      }
    }
    return user;
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    await _secureStorage.write(key: _keyUser, value: jsonEncode(user));
  }

  Future<void> _saveSession(
    String accessToken,
    String refreshToken,
    Map<String, dynamic> user,
  ) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    await _secureStorage.write(key: _keyUser, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>> getMfaStatus() async {
    return await _service.getMfaStatus();
  }

  Future<User> toggleMfaMethod(MfaMethod method, bool enabled) async {
    var user = await _service.toggleMfaMethod(method, enabled);
    user = await _ensureClientData(user, user.toJson());
    await _saveUser(user.toJson());
    return user;
  }

  Future<User> disableTotp(String password) async {
    var user = await _service.disableTotp(password);
    user = await _ensureClientData(user, user.toJson());
    await _saveUser(user.toJson());
    return user;
  }

  Future<Map<String, dynamic>> startTotpSetup() async {
    return await _service.startTotpSetup();
  }

  Future<Map<String, dynamic>> completeTotpSetup(String setupToken, String verificationCode) async {
    final res = await _service.completeTotpSetup(setupToken, verificationCode);
    if (res['success'] == true && res['user'] != null) {
      var user = User.fromJson(res['user'] as Map<String, dynamic>);
      user = await _ensureClientData(user, user.toJson());
      await _saveUser(user.toJson());
    }
    return res;
  }

  ApiClient get client => _apiClient;
}
