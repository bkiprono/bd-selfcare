import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/models/common/invoice.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/paginated_data.dart';
import 'package:bdoneapp/models/common/http_response.dart';

class InvoiceService {
  final ApiClient _apiClient;
  InvoiceService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Invoice> fetchInvoiceById(String invoiceId) async {
    final url = '${ApiEndpoints.invoices}/$invoiceId';
    final response = await _apiClient.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Invoice.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch invoice: ${response.statusCode}');
  }

  Future<PaginatedData<Invoice>> fetchInvoices({
    String? clientId,
    int page = 1,
    int limit = 10,
    String? keyword,
    String? status,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (clientId != null && clientId.isNotEmpty) params['clientId'] = clientId;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _apiClient.get(ApiEndpoints.invoices, queryParameters: params);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = CustomHttpResponse.fromJson(
        response.data,
        (data) => PaginatedData<Invoice>.fromJson(
          data,
          (item) => Invoice.fromJson(item as Map<String, dynamic>),
        ),
      );
      return res.data;
    }
    throw Exception('Failed to fetch invoices: ${response.statusCode}');
  }

  /// Generates PDF for an invoice
  Future<Invoice> generateInvoicePdf(String invoiceId) async {
    final url = '${ApiEndpoints.invoices}/$invoiceId/regenerate-pdf';
    final response = await _apiClient.post(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Invoice.fromJson(response.data['data']);
    }
    throw Exception('Failed to generate invoice PDF: ${response.statusCode}');
  }
}
