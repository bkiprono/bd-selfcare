import 'package:dio/dio.dart';
import 'package:bdoneapp/components/logger_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioException(DioException e) {
    String message = 'An unexpected error occurred';
    int? statusCode = e.response?.statusCode;
    dynamic data = e.response?.data;

    // Log the error for debugging
    logger.e('DioException occurred', error: e, stackTrace: e.stackTrace);
    logger.e('Error type: ${e.type}');
    logger.e('Error message: ${e.message}');
    logger.e('Response: ${e.response}');

    try {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Connection timed out. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        // More specific error message for connection errors
        if (e.message?.contains('SocketException') == true) {
          message = 'Unable to connect to server. Please check your connection.';
        } else if (e.message?.contains('HandshakeException') == true ||
                   e.message?.contains('CERTIFICATE_VERIFY_FAILED') == true) {
          message = 'SSL certificate error. Please check server configuration.';
        } else {
          message = 'Connection error: ${e.message ?? "Unknown error"}';
        }
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
      } else if (e.type == DioExceptionType.unknown) {
        message = 'Network error: ${e.message ?? "Unknown error"}';
      }
    } catch (err) {
      logger.e('Error processing DioException', error: err);
      message = 'Failed to process server response';
    }

    return ApiException(message: message, statusCode: statusCode, data: data);
  }

  @override
  String toString() => message;
}
