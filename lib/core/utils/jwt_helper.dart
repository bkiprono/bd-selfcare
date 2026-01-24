import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:bdoneapp/components/logger_config.dart';

class JwtHelper {
  /// Decode JWT token
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded);
    } catch (e) {
      if (kDebugMode) {
        logger.e('Error decoding token', error: e);
      }
      return null;
    }
  }

  /// Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      final decoded = decodeToken(token);
      if (decoded == null) return true;

      final exp = decoded['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      return now.isAfter(expiryDate);
    } catch (e) {
      if (kDebugMode) {
        logger.e('Error checking token expiry', error: e);
      }
      return true;
    }
  }

  /// Get token expiry date
  static DateTime? getTokenExpiryDate(String token) {
    try {
      final decoded = decodeToken(token);
      if (decoded == null) return null;

      final exp = decoded['exp'];
      if (exp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      if (kDebugMode) {
        logger.e('Error getting token expiry date', error: e);
      }
      return null;
    }
  }

  /// Get user ID from token
  static String? getUserIdFromToken(String token) {
    try {
      final decoded = decodeToken(token);
      if (decoded == null) return null;

      return decoded['userId'] ?? decoded['id'] ?? decoded['sub'];
    } catch (e) {
      if (kDebugMode) {
        logger.e('Error getting user ID from token', error: e);
      }
      return null;
    }
  }
}
