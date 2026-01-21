import 'package:bdcomputing/models/products/product_category.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/components/logger_config.dart';
import 'package:bdcomputing/core/utils/api_client.dart';

class ProductCategoriesService {
  final ApiClient _apiClient;
  ProductCategoriesService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ProductCategory>> fetchProductCategories({
    int? limit,
    int? page,
    String? keyword,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (limit != null) queryParams['limit'] = limit;
    if (page != null) queryParams['page'] = page;
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;

    final response = await _apiClient.get(
      ApiEndpoints.productCategories,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200) {
      final data = response.data;

      if (data is Map && data['data'] is Map && data['data']['data'] is List) {
        final List productsJson = data['data']['data'];
        return productsJson
            .map<ProductCategory>((p) => ProductCategory.fromJson(p))
            .toList();
      } else if (data is List) {
        return data
            .map<ProductCategory>((p) => ProductCategory.fromJson(p))
            .toList();
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  /// Fetch a single product category by its categoryId
  Future<ProductCategory?> fetchProductCategory(String categoryId) async {
    final response = await _apiClient.get('${ApiEndpoints.productCategories}/$categoryId');
    logger.d('fetchProductCategory response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return ProductCategory.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure for single category');
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load category: ${response.statusCode}');
    }
  }
}
