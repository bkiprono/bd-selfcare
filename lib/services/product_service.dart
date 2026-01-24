import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/product.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Product>> fetchProducts({int limit = -1, int page = 1, String keyword = ''}) async {
    final Map<String, dynamic> params = {
      'limit': limit,
      'page': page,
      'keyword': keyword,
    };

    final response = await _apiClient.get(ApiEndpoints.products, queryParameters: params);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // The structure is { data: { data: [List], ... } }
      // We need to access the inner 'data' which contains the list
      final dynamic responseData = response.data['data'];
      final List<dynamic> listData = responseData is Map && responseData.containsKey('data') 
            ? responseData['data'] 
            : responseData; // Fallback if it's already a list
      
      return listData.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch products: ${response.statusCode}');
  }
}
