import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/models/common/lead_project.dart';
import 'package:bdoneapp/models/common/project.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/paginated_data.dart';
import 'package:bdoneapp/models/common/http_response.dart';

class LeadProjectService {
  final ApiClient _apiClient;
  LeadProjectService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Create a new lead project (quote request)
  Future<LeadProject> createLeadProject(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.leadProjects, data: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LeadProject.fromJson(response.data['data']);
      }
      
      // Extract error message from response
      final errorMessage = response.data?['message'] ?? 'Failed to create lead project';
      throw Exception('$errorMessage (Status: ${response.statusCode})');
    } catch (e) {
      // Re-throw with more context
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create lead project: $e');
    }
  }

  Future<LeadProject> fetchLeadProjectById(String leadProjectId) async {
    final url = '${ApiEndpoints.leadProjects}/$leadProjectId';
    final response = await _apiClient.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LeadProject.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch lead project: ${response.statusCode}');
  }

  Future<PaginatedData<LeadProject>> fetchLeadProjects({
    String? clientId,
    String? leadId,
    int page = 1,
    int limit = 10,
    String? keyword,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (clientId != null && clientId.isNotEmpty) params['clientId'] = clientId;
    if (leadId != null && leadId.isNotEmpty) params['leadId'] = leadId;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

    final response = await _apiClient.get(ApiEndpoints.leadProjects, queryParameters: params);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = CustomHttpResponse.fromJson(
        response.data,
        (data) => PaginatedData<LeadProject>.fromJson(
          data,
          (item) => LeadProject.fromJson(item as Map<String, dynamic>),
        ),
      );
      return res.data;
    }
    throw Exception('Failed to fetch lead projects: ${response.statusCode}');
  }

  /// Convert lead project to project (called when client approves quote)
  Future<Project> convertToProject(
    String leadProjectId,
    Map<String, dynamic> payload,
  ) async {
    final url = '${ApiEndpoints.leadProjects}/$leadProjectId/convert-to-project';
    final response = await _apiClient.post(url, data: payload);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Project.fromJson(response.data['data']);
    }
    throw Exception('Failed to convert lead project to project: ${response.statusCode}');
  }
}
