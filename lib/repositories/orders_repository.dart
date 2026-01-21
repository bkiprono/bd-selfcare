import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/models/orders/order.dart';

class OrdersRepository {
  final ApiClient _client;

  OrdersRepository({required ApiClient client}) : _client = client;

  /// Get all orders with pagination
  Future<OrdersResponse> getOrders({int page = 1, int limit = 10}) async {
    final response = await _client.get(
      '${ApiEndpoints.orders}?page=$page&limit=$limit',
    );

    // Dio already parses the JSON
    final jsonData = response.data as Map<String, dynamic>;

    // Extract the nested data object
    final dataObject = jsonData['data'] as Map<String, dynamic>;

    // Parse orders from the nested data array
    final ordersData = dataObject['data'] as List<dynamic>;
    final orders = ordersData.map((item) => Order.fromJson(item)).toList();

    return OrdersResponse(
      data: orders,
      page: page,
      pages: ((dataObject['total'] as int) / limit).ceil(),
      total: dataObject['total'] as int,
    );
  }

  /// Get a single order by ID
  Future<Order> getOrderById(String orderId) async {
    final response = await _client.get('${ApiEndpoints.orders}/$orderId');

    final data = response.data as Map<String, dynamic>;
    return Order.fromJson(data['data']);
  }

  /// Create a standard product order from cart items
  Future<Map<String, dynamic>> createProductOrder(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post(ApiEndpoints.orders, data: payload);

    return response.data as Map<String, dynamic>;
  }

  /// Search orders by various criteria
  Future<OrdersResponse> searchOrders({
    String? query,
    OrderStatusEnum? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
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

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await _client.get(
      '${ApiEndpoints.orders}/search?$queryString',
    );

    final jsonData = response.data as Map<String, dynamic>;

    // Extract the nested data object
    final dataObject = jsonData['data'] as Map<String, dynamic>;

    // Parse orders from the nested data array
    final ordersData = dataObject['data'] as List<dynamic>;
    final orders = ordersData.map((item) => Order.fromJson(item)).toList();

    return OrdersResponse(
      data: orders,
      page: page,
      pages: ((dataObject['total'] as int) / limit).ceil(),
      total: dataObject['total'] as int,
    );
  }
}
