import 'package:dio/dio.dart';
import 'package:bdcomputing/core/interceptors/dio_interceptor.dart';

class DioApiClient {
  late final Dio _dio;

  Dio get http => _dio;

  DioApiClient() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor(_dio));
  }
}
