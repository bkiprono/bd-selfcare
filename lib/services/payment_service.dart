import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/endpoints.dart';

class PaymentService {
  final ApiClient _apiClient;
  PaymentService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<dynamic> payWithMpesa(String invoiceId, String phoneNumber) async {
    final url = '${ApiEndpoints.mpesaStkPush}/$invoiceId';
    final response = await _apiClient.post(url, data: {'phoneNumber': phoneNumber});
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
}
