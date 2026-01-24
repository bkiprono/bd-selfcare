import 'package:dio/dio.dart';
import 'package:bdcomputing/screens/auth/domain/password_model.dart';
import 'package:bdcomputing/screens/auth/domain/user_model.dart';
import 'package:bdcomputing/screens/auth/domain/client_registration_model.dart';
import 'package:bdcomputing/screens/auth/domain/mfa_models.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/utils/api_exception.dart';

class AuthService {
  final ApiClient _apiClient;
  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<LoginResult> loginWithEmail({required String email, required String password}) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.loginWithEmailEndpoint,
        data: {'email': email, 'password': password},
      );

      final root = res.data as Map<String, dynamic>;
      final payload = (root['data'] ?? root) as Map<String, dynamic>;

      // Handle MFA required
      if (payload['mfaToken'] != null) {
        return MfaRequired(
          mfaToken: payload['mfaToken'] as String,
          mfaMethods: (payload['mfaMethods'] as List?)
                  ?.map((e) => MfaMethod.fromString(e.toString()))
                  .toList() ??
              [],
        );
      }

      final userBody = payload['user'];
      if (userBody == null) {
        throw ApiException(message: 'User data not found in response');
      }
      
      // Include vendor data if present in the response
      final userMap = userBody as Map<String, dynamic>;
      if (payload['client'] != null) {
        userMap['client'] = payload['client'];
      }
      
      final user = User.fromJson(userMap);
      if (user.clientId == null) {
        throw ApiException(message: 'User is not a client');
      }

      return LoginSuccess(
        accessToken:
            (payload['access_token'] ?? payload['accessToken'] ?? '') as String,
        refreshToken:
            (payload['refresh_token'] ?? payload['refreshToken'] ?? '')
                as String,
        user: user.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<LoginResult> loginWithPhone({required String phone, required String password}) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.loginWithPhoneEndpoint,
        data: {'phone': phone, 'password': password},
      );

      final root = res.data as Map<String, dynamic>;
      final payload = (root['data'] ?? root) as Map<String, dynamic>;

      // Handle MFA required
      if (payload['mfaToken'] != null) {
        return MfaRequired(
          mfaToken: payload['mfaToken'] as String,
          mfaMethods: (payload['mfaMethods'] as List?)
                  ?.map((e) => MfaMethod.fromString(e.toString()))
                  .toList() ??
              [],
        );
      }

      final userBody = payload['user'];
      if (userBody == null) {
        throw ApiException(message: 'User data not found in response');
      }
      final user = User.fromJson(userBody as Map<String, dynamic>);
      if (user.clientId == null) {
        throw ApiException(message: 'User is not a client');
      }
      return LoginSuccess(
        accessToken:
            (payload['access_token'] ?? payload['accessToken'] ?? '') as String,
        refreshToken:
            (payload['refresh_token'] ?? payload['refreshToken'] ?? '')
                as String,
        user: user.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _apiClient.post(
      ApiEndpoints.resetPasswordEndpoint,
      data: {'email': email, 'useOTP': true},
    );

    final body = res.data as Map<String, dynamic>;
    return {
      'statusCode': res.statusCode,
      ...body,
    };
  }

  Future<Map<String, dynamic>> updatePassword(UpdatePasswordModel password) async {
    final res = await _apiClient.post(
      ApiEndpoints.updatePasswordWithOTPEndpoint,
      data: password.toJson(),
    );

    final body = res.data as Map<String, dynamic>;
    return {
      'statusCode': res.statusCode,
      ...body,
    };
  }

  Future<({String accessToken, String refreshToken, Map<String, dynamic>? user})> refreshToken(
    String refreshToken,
  ) async {
    // Note: Use a raw dio call or unauthenticated client for refresh to avoid interceptor circles if any
    final res = await _apiClient.post(
      ApiEndpoints.refreshTokenEndpoint,
      data: {'refresh_token': refreshToken}, // Body can stay as some systems use it, but header is key
      options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
    );

    if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
      final root = res.data as Map<String, dynamic>;
      final payload = (root['data'] ?? root) as Map<String, dynamic>;
      final userBody = payload['user'];
      return (
        accessToken:
            (payload['access_token'] ?? payload['accessToken'] ?? '') as String,
        refreshToken:
            (payload['refresh_token'] ??
                    payload['refreshToken'] ??
                    refreshToken)
                as String,
        user: userBody != null ? userBody as Map<String, dynamic> : null,
      );
    }
    throw Exception('Failed to refresh token');
  }

  Future<void> signup(ClientRegistration client) async {
    try {
      await _apiClient.post(
        ApiEndpoints.registerEndpoint,
        data: client.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<LoginSuccess> verifyMfa({
    required String mfaToken,
    required String code,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.mfaVerifyEndpoint,
        data: {'mfaToken': mfaToken, 'code': code},
      );

      final root = res.data as Map<String, dynamic>;
      final payload = (root['data'] ?? root) as Map<String, dynamic>;

      final userBody = payload['user'];
      if (userBody == null) {
        throw ApiException(message: 'User data not found in response');
      }

      final user = User.fromJson(userBody as Map<String, dynamic>);
      if (user.clientId == null) {
        throw ApiException(message: 'User is not a client');
      }

      return LoginSuccess(
        accessToken:
            (payload['access_token'] ?? payload['accessToken'] ?? '') as String,
        refreshToken:
            (payload['refresh_token'] ?? payload['refreshToken'] ?? '')
                as String,
        user: user.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<LoginResult> loginWithGoogle(String idToken) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.loginWithGoogleEndpoint,
        data: {'idToken': idToken},
      );

      return _handleLoginResponse(res);
    } on DioException catch (e) {
      if (e.response?.statusCode == 202) {
        final data = e.response?.data['data'] ?? e.response?.data;
        return LoginAccepted(
          tempToken: data['tempToken'] as String,
          email: data['email'] as String,
        );
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<LoginResult> confirmGoogleLogin({
    required String tempToken,
    required String password,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.confirmGoogleLoginEndpoint,
        data: {'tempToken': tempToken, 'password': password},
      );

      return _handleLoginResponse(res);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  LoginResult _handleLoginResponse(Response res) {
    final root = res.data as Map<String, dynamic>;
    final payload = (root['data'] ?? root) as Map<String, dynamic>;

    // Handle MFA required
    if (payload['mfaToken'] != null) {
      return MfaRequired(
        mfaToken: payload['mfaToken'] as String,
        mfaMethods: (payload['mfaMethods'] as List?)
                ?.map((e) => MfaMethod.fromString(e.toString()))
                .toList() ??
            [],
      );
    }

    final userBody = payload['user'];
    if (userBody == null) {
      throw ApiException(message: 'User data not found in response');
    }

    // Include vendor data if present in the response
    final userMap = userBody as Map<String, dynamic>;
    if (payload['client'] != null) {
      userMap['client'] = payload['client'];
    }

    final user = User.fromJson(userMap);
    if (user.clientId == null) {
      throw ApiException(message: 'User is not a client');
    }

    return LoginSuccess(
      accessToken:
          (payload['access_token'] ?? payload['accessToken'] ?? '') as String,
      refreshToken:
          (payload['refresh_token'] ?? payload['refreshToken'] ?? '') as String,
      user: user.toJson(),
    );
  }

  Future<void> resendMfa(String mfaToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.mfaResendEndpoint,
        data: {'mfaToken': mfaToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
