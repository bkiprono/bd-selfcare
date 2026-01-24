import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/product.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Product>> fetchProducts() async {
    final response = await _apiClient.get(ApiEndpoints.products);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch products: ${response.statusCode}');
  }
}
