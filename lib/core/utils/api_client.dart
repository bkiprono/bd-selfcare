import 'package:dio/dio.dart';
import 'package:bdcomputing/core/config/env_config.dart';
import 'package:bdcomputing/components/logger_config.dart';

typedef TokenProvider = Future<String?> Function();
typedef RefreshCallback = Future<bool> Function();

class ApiClient {
  late final Dio dio;
  final String baseUrl;
  final TokenProvider? getAccessToken;
  final RefreshCallback? onRefreshToken;

  ApiClient({
    required this.baseUrl,
    this.getAccessToken,
    this.onRefreshToken,
  }) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: EnvConfig.connectTimeout,
      receiveTimeout: EnvConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (getAccessToken != null) {
          final token = await getAccessToken!();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && onRefreshToken != null) {
          final success = await onRefreshToken!();
          if (success) {
            // Retry the request
            final options = e.requestOptions;
            if (getAccessToken != null) {
              final token = await getAccessToken!();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
            try {
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (retryError) {
              return handler.next(e);
            }
          }
        }
        return handler.next(e);
      },
    ));

    // Add logging interceptor if needed
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => logger.d(obj.toString()),
    ));
  }

  Future<Response> get(String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }
  
  Future<Response> post(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }
  
  Future<Response> put(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }
  
  Future<Response> patch(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }
  
  Future<Response> delete(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }
}
