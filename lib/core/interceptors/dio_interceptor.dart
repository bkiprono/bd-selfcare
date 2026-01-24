import 'package:dio/dio.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/core/utils/store.dart';
import 'package:bdoneapp/core/utils/jwt_helper.dart';
import 'package:bdoneapp/components/logger_config.dart';

class DioInterceptor extends QueuedInterceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  DioInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await Store.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      // Check if token is expired before making the request
      if (JwtHelper.isTokenExpired(accessToken)) {
        // Token is expired, try to refresh it
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          final newToken = await Store.getAccessToken();
          if (newToken != null && newToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $newToken';
          }
        } else {
          // Refresh failed, clear tokens and let the request proceed without auth
          await Store.clearTokens();
        }
      } else {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    options.headers['Content-Type'] = 'application/json';

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token is invalid, try to refresh
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        // Retry the original request with new token
        final newToken = await Store.getAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await _dio.fetch(err.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // Retry failed, proceed with original error
          }
        }
      } else {
        // Refresh failed, clear tokens
        await Store.clearTokens();
      }
    }

    super.onError(err, handler);
  }

  Future<bool> _refreshTokenIfNeeded() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh to complete
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return true;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await Store.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        logger.i('No refresh token available (interceptor)');
        return false;
      }

      // Don't attempt refresh with an expired refresh token
      if (JwtHelper.isTokenExpired(refreshToken)) {
        logger.i('Refresh token expired (interceptor)');
        await Store.clearTokens();
        return false;
      }

      final masked = refreshToken.length > 10
          ? '${refreshToken.substring(0, 5)}...${refreshToken.substring(refreshToken.length - 5)}'
          : '***masked***';
      logger.i('Refreshing via interceptor with refresh_token: $masked');

      // Call refresh token endpoint
      final dio = Dio();
      final response = await dio.post(
        ApiEndpoints.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken =
            data['data']['access_token'] ?? data['access_token'];
        final newRefreshToken =
            data['data']['refresh_token'] ??
            data['refresh_token'] ??
            refreshToken;

        await Store.setAccessToken(accessToken);
        await Store.setRefreshToken(newRefreshToken);
        return true;
      }
      return false;
    } catch (e, s) {
      logger.e('Token refresh failed', error: e, stackTrace: s);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
