import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/models/common/statement.dart';
import 'package:bdoneapp/models/common/request_statement_dto.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/paginated_data.dart';
import 'package:bdoneapp/models/common/http_response.dart';

class StatementsService {
  final ApiClient _apiClient;
  StatementsService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Request a new statement
  Future<Statement> requestStatement(RequestStatementDto dto) async {
    final response = await _apiClient.post(
      ApiEndpoints.statements,
      data: dto.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Statement.fromJson(response.data['data']);
    }
    throw Exception('Failed to request statement: ${response.statusCode}');
  }

  /// Fetch statements for the current client
  Future<PaginatedData<Statement>> fetchStatements({
    String? clientId,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };

    // Use the client-specific endpoint if clientId is provided
    final url = clientId != null
        ? '${ApiEndpoints.statements}/client/$clientId'
        : ApiEndpoints.statements;

    final response = await _apiClient.get(url, queryParameters: params);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Backend returns IResponse<IPaginatedResponse<Statement[]>>
      // So we need to extract from response.data['data'] which contains the paginated data
      final responseData = response.data['data'];
      
      if (responseData != null && responseData['data'] != null) {
        // Extract the actual paginated response
        return PaginatedData<Statement>.fromJson(
          responseData,
          (item) => Statement.fromJson(item as Map<String, dynamic>),
        );
      }
      
      // Fallback to empty paginated data
      return PaginatedData<Statement>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        pages: 0,
      );
    }
    throw Exception('Failed to fetch statements: ${response.statusCode}');
  }

  /// Fetch a single statement by ID
  Future<Statement> fetchStatementById(String statementId) async {
    final url = ApiEndpoints.statementById(statementId);
    final response = await _apiClient.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Statement.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch statement: ${response.statusCode}');
  }

  /// Regenerate statement PDF
  Future<Statement> regenerateStatementPdf(String statementId) async {
    final url = ApiEndpoints.regenerateStatementPdf(statementId);
    final response = await _apiClient.post(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Statement.fromJson(response.data['data']);
    }
    throw Exception('Failed to regenerate statement PDF: ${response.statusCode}');
  }

  /// Get statement data with transactions
  Future<Map<String, dynamic>> getStatementData(String statementId) async {
    final url = ApiEndpoints.statementDataById(statementId);
    final response = await _apiClient.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Backend now returns IResponse wrapper, extract the actual data
      final responseData = response.data['data'];
      return responseData ?? {};
    }
    throw Exception('Failed to fetch statement data: ${response.statusCode}');
  }
}
