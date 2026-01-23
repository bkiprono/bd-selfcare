import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/models/common/quote.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';
import 'package:bdcomputing/models/common/http_response.dart';

class QuoteService {
  final ApiClient _apiClient;
  QuoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Quote> fetchQuoteById(String quoteId) async {
    final url = '${ApiEndpoints.quotes}/$quoteId';
    final response = await _apiClient.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Quote.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch quote: ${response.statusCode}');
  }

  Future<PaginatedData<Quote>> fetchQuotes({
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

    final response = await _apiClient.get(ApiEndpoints.quotes, queryParameters: params);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = CustomHttpResponse.fromJson(
        response.data,
        (data) => PaginatedData<Quote>.fromJson(
          data,
          (item) => Quote.fromJson(item as Map<String, dynamic>),
        ),
      );
      return res.data;
    }
    throw Exception('Failed to fetch quotes: ${response.statusCode}');
  }
}
