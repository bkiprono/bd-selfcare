import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/models/common/settings.dart';
import 'package:bdcomputing/core/utils/api_client.dart';

class SettingsService {
  final ApiClient _apiClient;
  SettingsService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<SettingsResponse> fetch() async {
    final response = await _apiClient.get(ApiEndpoints.settings);

    if (response.statusCode == 200) {
      final jsonBody = response.data as Map<String, dynamic>;
      return SettingsResponse.fromJson(jsonBody);
    }

    throw Exception('Failed to load settings: ${response.statusCode}');
  }
}
