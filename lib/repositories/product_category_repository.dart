import 'package:bdcomputing/models/products/product_category.dart';
import 'package:bdcomputing/services/product_categories_service.dart';

class ProductCategoryRepository {
  final ProductCategoriesService _service;
  ProductCategoryRepository({required ProductCategoriesService service}) : _service = service;

  Future<List<ProductCategory>> getAllProducts({
    int? limit,
    int? page,
    String? keyword,
  }) async {
    try {
      return await _service.fetchProductCategories(
        limit: limit,
        page: page,
        keyword: keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductCategory?> getProductById(String id) async {
    try {
      return await _service.fetchProductCategory(id);
    } catch (e) {
      rethrow;
    }
  }
}