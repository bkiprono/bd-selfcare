import 'package:bdcomputing/models/common/address.dart';
import 'package:bdcomputing/core/utils/store.dart';
import 'package:bdcomputing/core/utils/api.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/components/logger_config.dart';

class AuthenticationService extends DioApiClient {
  Map<String, dynamic> get userData => {'email': '', 'useOTP': true};

  Map<String, dynamic> get _loginData => {'email': '', 'password': ''};

  Future<void> saveAccessToken(Map<String, dynamic> data) async {
    final accessToken = data['data']['access_token'];
    final refreshToken = data['data']['refresh_token'];
    await Store.setAccessToken(accessToken);
    await Store.setRefreshToken(refreshToken);
  }

  Future<bool> login() async {
    try {
      final response = await http.post(
        ApiEndpoints.loginWithEmailEndpoint,
        data: _loginData,
      );
      if (response.statusCode == 200) {
        await saveAccessToken(response.data);
        return true;
      }
      return false;
    } catch (e, s) {
      logger.e('Login error', error: e, stackTrace: s);
      return false;
    }
  }

  Future<String> resetPassword() async {
    try {
      final response = await http.post(
        ApiEndpoints.resetPasswordEndpoint,
        data: userData,
      );
      if (response.statusCode == 200) {
        return 'Email sent to the user with the email ${userData['email']}';
      }
      return 'There was an issue resetting the password for the user with the email ${userData['email']}';
    } catch (e, s) {
      logger.e('Reset password error', error: e, stackTrace: s);
      return 'There was an issue resetting the password for the user with the email ${userData['email']}';
    }
  }

  Future<List<Address>> getAddresses() async {
    try {
      final response = await http.get(ApiEndpoints.addresses);
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          return list.whereType<Map<String, dynamic>>().map((e) {
            return Address.fromJson(e);
          }).toList();
        }
      }
      return <Address>[];
    } catch (e, s) {
      logger.e('Get addresses error', error: e, stackTrace: s);
      return [];
    }
  }
}
