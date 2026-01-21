import 'package:dio/dio.dart';
import 'package:bdcomputing/screens/auth/domain/password_model.dart';
import 'package:bdcomputing/screens/auth/domain/user_model.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/models/common/vendor.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/utils/api_exception.dart';

class AuthService {
  final ApiClient _apiClient;
  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<({String accessToken, String refreshToken, Map<String, dynamic> user})>
  loginWithEmail({required String email, required String password}) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.loginWithEmailEndpoint,
        data: {'email': email, 'password': password},
      );

      final root = res.data as Map<String, dynamic>;
      final payload = (root['data'] ?? root) as Map<String, dynamic>;
      final userBody = payload['user'];
      if (userBody == null) {
        throw ApiException(message: 'User data not found in response');
      }
      
      // Include vendor data if present in the response
      final userMap = userBody as Map<String, dynamic>;
      if (payload['vendor'] != null) {
        userMap['vendor'] = payload['vendor'];
      }
      
      final user = User.fromJson(userMap);
      if (user.vendorId == null) {
        throw ApiException(message: 'User is not a vendor');
      }

      return (
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

  Future<({String accessToken, String refreshToken, Map<String, dynamic> user})>
  loginWithPhone({required String phone, required String password}) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.loginWithPhoneEndpoint,
        data: {'phone': phone, 'password': password},
      );

      final root = res.data as Map<String, dynamic>;
      final payload = (root['data'] ?? root) as Map<String, dynamic>;
      final userBody = payload['user'];
      if (userBody == null) {
        throw ApiException(message: 'User data not found in response');
      }
      final user = User.fromJson(userBody as Map<String, dynamic>);
      if (user.customerId == null) {
        throw ApiException(message: 'User is not a customer');
      }
      return (
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

  Future<void> signup(VendorRegister vendor) async {
    try {
      await _apiClient.post(
        ApiEndpoints.registerEndpoint,
        data: vendor.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
