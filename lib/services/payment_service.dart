import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/models/payments/payment.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';
import 'package:bdcomputing/models/common/http_response.dart';

class PaymentService {
  final ApiClient _apiClient;
  PaymentService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<dynamic> payWithMpesa(String invoiceId, String phoneNumber, {double? amount}) async {
    final url = '${ApiEndpoints.mpesaStkPush}/$invoiceId';
    final Map<String, dynamic> data = {'phoneNumber': phoneNumber};
    if (amount != null) data['amount'] = amount;
    
    final response = await _apiClient.post(url, data: data);
    if (response.statusCode != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return response.data;
    }
    throw Exception('Failed to initiate mpesa payment: ${response.statusCode}');
  }

  Future<dynamic> getMpesaPaymentStatus(String checkoutRequestID) async {
    final url = '${ApiEndpoints.mpesaPaymentStatus}/$checkoutRequestID';
    final response = await _apiClient.get(url);
    if (response.statusCode != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return response.data;
    }
    throw Exception('Failed to fetch mpesa stk push payment status: ${response.statusCode}');
  }

  Future<dynamic> payWithPesapal(String invoiceId) async {
    final url = '${ApiEndpoints.pesapalPayment}/$invoiceId';
    final response = await _apiClient.post(url);
    if (response.statusCode != null && (response.statusCode == 200 || response.statusCode == 201)) {
      return response.data;
    }
    throw Exception('Failed to fetch pesapal payment: ${response.statusCode}');
  }

  Future<PaginatedData<Payment>> fetchPayments({
    String? clientId,
    String? invoiceId,
    int page = 1,
    int limit = 10,
    String? keyword,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (clientId != null && clientId.isNotEmpty) params['clientId'] = clientId;
    if (invoiceId != null && invoiceId.isNotEmpty) params['invoiceId'] = invoiceId;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

    final response = await _apiClient.get(ApiEndpoints.payments, queryParameters: params);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = CustomHttpResponse.fromJson(
        response.data,
        (data) => PaginatedData<Payment>.fromJson(
          data,
          (item) => Payment.fromJson(item as Map<String, dynamic>),
        ),
      );
      return res.data;
    }
    throw Exception('Failed to fetch payments: ${response.statusCode}');
  }
}
