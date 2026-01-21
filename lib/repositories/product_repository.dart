import 'package:bdcomputing/models/products/product.dart';
import 'package:bdcomputing/services/products_service.dart';
import 'package:bdcomputing/models/products/manage_product.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';

class ProductRepository {
  final ProductService _service;
  ProductRepository({required ProductService service}) : _service = service;

  Future<PaginatedData<Product>> fetchProducts({
    required int limit,
    String? categoryId,
    String? subCategoryId,
    String? keyword,
    int? page,
  }) async {
    try {
      return await _service.fetchProducts(
        limit: limit,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        keyword: keyword,
        page: page,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Product?> getProductBySlug(String slug) async {
    try {
      final product = await _service.fetchProductBySlug(slug);
      return product;
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> createProduct(CreateProductModel product) async {
    try {
      return await _service.createProduct(product);
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> updateProduct(String productId, CreateProductModel product) async {
    try {
      return await _service.updateProduct(productId, product);
    } catch (e) {
      rethrow;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      return await _service.fetchProductById(id);
    } catch (e) {
      rethrow;
    }
  }
  Future<void> uploadMedia(String productId, List<String> filePaths, String type) async {
    try {
      await _service.uploadMedia(
        productId: productId,
        filePaths: filePaths,
        type: type,
      );
    } catch (e) {
      rethrow;
    }
  }
}
