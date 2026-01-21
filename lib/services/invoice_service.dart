import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/models/common/invoice.dart';
import 'package:bdcomputing/core/endpoints.dart';

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
}
