import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioException(DioException e) {
    String message = 'An unexpected error occurred';
    int? statusCode = e.response?.statusCode;
    dynamic data = e.response?.data;

    try {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Connection timed out. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'No internet connection.';
      } else if (e.response != null) {
        // Try to extract message from response body
        final responseData = e.response?.data;
        if (responseData is Map) {
          message = responseData['message'] ?? 
                    responseData['error'] ?? 
                    'Server error: $statusCode';
          
          // Handle specific validation errors if they exist
          if (responseData['errors'] != null) {
            final errors = responseData['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                message = firstError.first.toString();
              } else {
                message = firstError.toString();
              }
            }
          }
        } else {
          message = 'Server error: $statusCode';
        }
      } else if (e.type == DioExceptionType.cancel) {
        message = 'Request was cancelled';
      }
    } catch (_) {
      message = 'Failed to process server response';
    }

    return ApiException(message: message, statusCode: statusCode, data: data);
  }

  @override
  String toString() => message;
}
