import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/term_model.dart';
import 'package:bdoneapp/core/utils/api_client.dart';

class TermsService {
  final ApiClient _apiClient;
  TermsService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Term>> fetchTermsAndConditions() async {
    final response = await _apiClient.get(ApiEndpoints.terms);

    if (response.statusCode == 200) {
      final data = response.data;

      if (data is Map && data['data'] is List) {
        final List<dynamic> termsData = data['data'];
        return termsData.map((json) => Term.fromJson(json)).toList();
      } else if (data is Map &&
          data['data'] is Map &&
          data['data']['data'] is List) {
        final List<dynamic> termsData = data['data']['data'];
        return termsData.map((json) => Term.fromJson(json)).toList();
      } else if (data is List) {
        return data.map<Term>((json) => Term.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      throw Exception('Failed to load terms: ${response.statusCode}');
    }
  }

  /// Fetch a single term by its ID
  Future<Term?> fetchTermById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.terms}/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return Term.fromJson(data['data'] as Map<String, dynamic>);
      } else if (data is Map) {
        return Term.fromJson(Map<String, dynamic>.from(data));
      } else {
         throw Exception('Unexpected API response structure');
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load term: ${response.statusCode}');
    }
  }
}
