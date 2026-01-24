import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/service.dart';

class ServiceService {
  final ApiClient _apiClient;
  ServiceService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ServiceModel>> fetchServices({int limit = -1, int page = 1, String keyword = ''}) async {
    final Map<String, dynamic> params = {
      'limit': limit,
      'page': page,
      'keyword': keyword,
    };

    final response = await _apiClient.get(ApiEndpoints.services, queryParameters: params);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // The structure is { data: { data: [List], ... } }
      final dynamic responseData = response.data['data'];
      final List<dynamic> listData = responseData is Map && responseData.containsKey('data') 
            ? responseData['data'] 
            : responseData; // Fallback if it's already a list
      
      return listData.map((json) => ServiceModel.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch services: ${response.statusCode}');
  }
}
