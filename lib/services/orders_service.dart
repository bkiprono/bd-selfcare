import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/models/orders/order.dart';
import 'package:bdcomputing/core/utils/api_client.dart';

class OrdersService {
  final ApiClient _apiClient;
  OrdersService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all orders with pagination
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.orders,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data as Map<String, dynamic>;
      return {
        'statusCode': response.statusCode,
        'message': jsonResponse['message'] ?? 'Success',
        'data': OrdersResponse.fromJson(jsonResponse),
      };
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    } else {
      final errorBody = response.data as Map<String, dynamic>;
      throw Exception(errorBody['message'] ?? 'Failed to fetch orders');
    }
  }

  /// Get a single order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await _apiClient.get('${ApiEndpoints.orders}/$orderId');

    if (response.statusCode == 200) {
      final jsonResponse = response.data as Map<String, dynamic>;
      return {
        'statusCode': response.statusCode,
        'message': jsonResponse['message'] ?? 'Success',
        'data': Order.fromJson(jsonResponse['data']),
      };
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    } else {
      final errorBody = response.data as Map<String, dynamic>;
      throw Exception(errorBody['message'] ?? 'Failed to fetch order details');
    }
  }

  /// Search orders by various criteria
  Future<Map<String, dynamic>> searchOrders({
    String? query,
    OrderStatusEnum? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (query != null && query.isNotEmpty) {
      queryParams['query'] = query;
    }
    if (status != null) {
      queryParams['status'] = status.value;
    }
    if (dateFrom != null) {
      queryParams['dateFrom'] = dateFrom;
    }
    if (dateTo != null) {
      queryParams['dateTo'] = dateTo;
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.orders}/search',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data as Map<String, dynamic>;
      return {
        'statusCode': response.statusCode,
        'message': jsonResponse['message'] ?? 'Success',
        'data': OrdersResponse.fromJson(jsonResponse),
      };
    } else {
      throw Exception('Failed to search orders');
    }
  }
}
