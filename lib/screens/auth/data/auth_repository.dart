import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:bdcomputing/screens/auth/domain/auth_state.dart';
import 'package:bdcomputing/screens/auth/domain/password_model.dart';
import 'package:bdcomputing/screens/auth/domain/user_model.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/utils/jwt_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bdcomputing/screens/auth/data/auth_service.dart';
import 'package:bdcomputing/services/vendor_service.dart';

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

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<AuthState> restoreSession() async {
    final accessToken = await _secureStorage.read(key: _keyAccessToken);
    final refreshToken = await _secureStorage.read(key: _keyRefreshToken);
    final userJson = await _secureStorage.read(key: _keyUser);

    if (accessToken == null || refreshToken == null || userJson == null) {
      return const Unauthenticated();
    }

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = User.fromJson(userMap);

      // Validate access token
      if (JwtHelper.isTokenExpired(accessToken)) {
        // Token is expired, try to refresh
        final refreshed = await this.refreshToken();
        if (!refreshed) {
          // Refresh failed, clear session
          await logout();
          return const Unauthenticated();
        }
      }

      return Authenticated(user);
    } catch (e) {
      _logger.i('Error restoring session: $e');
      await logout();
      return const Unauthenticated();
    }
  }

  Future<AuthState> loginWithEmail(String email, String password) async {
    final result = await _service.loginWithEmail(
      email: email,
      password: password,
    );
    
    var userJson = result.user;
    var user = User.fromJson(userJson);
    
    // Ensure we have full vendor data including country
    user = await _ensureVendorData(user, userJson);
    
    await _saveSession(result.accessToken, result.refreshToken, user.toJson());
    return Authenticated(user);
  }

  Future<AuthState> loginWithPhone(String phone, String password) async {
    final result = await _service.loginWithPhone(
      phone: phone,
      password: password,
    );
    
    var userJson = result.user;
    var user = User.fromJson(userJson);
    
    // Ensure we have full vendor data including country
    user = await _ensureVendorData(user, userJson);
    
    await _saveSession(result.accessToken, result.refreshToken, user.toJson());
    return Authenticated(user);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _service.forgotPassword(email);
  }

  Future<Map<String, dynamic>> updatePassword(UpdatePasswordModel password) async {
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
    
    // Include vendor data if present in the response
    if (responsePayload['vendor'] != null) {
      userBody['vendor'] = responsePayload['vendor'];
    }
    
    var user = User.fromJson(userBody);
    
    // Ensure we have full vendor data including country
    user = await _ensureVendorData(user, userBody);
    
    await _saveUser(user.toJson());
    
    return user;
  }

  // Ensure user has complete vendor data (fetched if necessary)
  Future<User> _ensureVendorData(User user, Map<String, dynamic> userJson) async {
    // If user has a vendorId but vendor object or country is missing, fetch it
    if (user.vendorId != null && (user.vendor == null || user.vendor?.country == null)) {
      try {
        final vendorService = VendorService(apiClient: _apiClient);
        final vendor = await vendorService.getMyVendor();
        if (vendor != null) {
          userJson['vendor'] = vendor.toJson();
          return User.fromJson(userJson);
        }
      } catch (e) {
        _logger.w('Failed to fetch full vendor data: $e');
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

  ApiClient get client => _apiClient;
}
