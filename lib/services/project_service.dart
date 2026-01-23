import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/models/common/project.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';
import 'package:bdcomputing/models/common/http_response.dart';

class ProjectService {
  final ApiClient _apiClient;
  ProjectService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Project> fetchProjectById(String projectId) async {
    final url = '${ApiEndpoints.projects}/$projectId';
    final response = await _apiClient.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Project.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch project: ${response.statusCode}');
  }

  Future<PaginatedData<Project>> fetchProjects({
    String? clientId,
    int page = 1,
    int limit = 10,
    String? keyword,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (clientId != null && clientId.isNotEmpty) params['clientId'] = clientId;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

    final response = await _apiClient.get(ApiEndpoints.projects, queryParameters: params);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = CustomHttpResponse.fromJson(
        response.data,
        (data) => PaginatedData<Project>.fromJson(
          data,
          (item) => Project.fromJson(item as Map<String, dynamic>),
        ),
      );
      return res.data;
    }
    throw Exception('Failed to fetch projects: ${response.statusCode}');
  }
}
