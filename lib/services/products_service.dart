import 'package:bdcomputing/components/logger_config.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:bdcomputing/models/products/manage_product.dart';
import 'package:bdcomputing/models/products/product.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch products with optional filters
  Future<PaginatedData<Product>> fetchProducts({
    int? limit,
    int? page,
    String? keyword,
    String? categoryId,
    String? subCategoryId,
    String? vendorId,
    bool? isPublished,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (limit != null) queryParams['limit'] = limit;
    if (page != null) queryParams['page'] = page;
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (subCategoryId != null && subCategoryId.isNotEmpty) {
      queryParams['subCategoryId'] = subCategoryId;
    }
    if (vendorId != null && vendorId.isNotEmpty) {
      queryParams['vendorId'] = vendorId;
    }
    if (isPublished != null) {
      queryParams['isPublished'] = isPublished;
    }

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Extract metadata if available
      if (data is Map && data['data'] is Map) {
        final Map<String, dynamic> responseData = data['data'];
        return PaginatedData.fromJson(
          responseData,
          (item) => Product.fromJson(item),
        );
      } else if (data is List) {
        // Fallback if the API returns a direct list (unlikely based on codebase)
        return PaginatedData(
          page: 1,
          limit: data.length,
          total: data.length,
          pages: 1,
          data: data.map<Product>((p) => Product.fromJson(p)).toList(),
        );
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  /// Fetch products for a specific vendor
  Future<PaginatedData<Product>> fetchVendorProducts(
    String vendorId, {
    int? limit,
    int? page,
    String? keyword,
  }) async {
    return fetchProducts(
      vendorId: vendorId,
      limit: limit,
      page: page,
      keyword: keyword,
    );
  }

  /// Fetch a single product by its slug
  Future<Product?> fetchProductBySlug(String slug) async {
    final response = await _apiClient.get('${ApiEndpoints.products}/$slug');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return Product.fromJson(data['data']);
      } else if (data is Map && data['data'] != null) {
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  /// Fetch a single product by its ID
  Future<Product?> fetchProductById(String productId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.products}/$productId',
    );
    logger.d('fetchProductById response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure for single product');
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  /// Create a new product
  Future<Product> createProduct(CreateProductModel product) async {
    logger.d('Creating product: ${product.name}');

    final response = await _apiClient.post(
      ApiEndpoints.createProduct,
      data: product.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        logger.d('Product created successfully');
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      logger.e('Failed to create product. Response: ${response.data}');
      final errorMessage =
          response.data is Map && response.data['message'] != null
          ? response.data['message']
          : 'Failed to create product';
      throw Exception(errorMessage);
    }
  }

  /// Update an existing product
  Future<Product> updateProduct(
    String productId,
    CreateProductModel product,
  ) async {
    logger.d('Updating product: $productId');

    final response = await _apiClient.patch(
      '${ApiEndpoints.updateProduct}/$productId',
      data: product.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        logger.d('Product updated successfully');
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      final errorMessage =
          response.data is Map && response.data['message'] != null
          ? response.data['message']
          : 'Failed to update product';
      throw Exception(errorMessage);
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    logger.d('Deleting product: $productId');

    final response = await _apiClient.delete(
      '${ApiEndpoints.products}/$productId',
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      logger.d('Product deleted successfully');
      return true;
    } else {
      final errorMessage =
          response.data is Map && response.data['message'] != null
          ? response.data['message']
          : 'Failed to delete product';
      throw Exception(errorMessage);
    }
  }

  /// Publish a product
  Future<Product> publishProduct(String productId) async {
    logger.d('Publishing product: $productId');

    final response = await _apiClient.patch(
      '${ApiEndpoints.products}/$productId',
      data: {'isPublished': true},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        logger.d('Product published successfully');
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      throw Exception('Failed to publish product');
    }
  }

  /// Unpublish a product
  Future<Product> unpublishProduct(String productId) async {
    logger.d('Unpublishing product: $productId');

    final response = await _apiClient.patch(
      '${ApiEndpoints.products}/$productId',
      data: {'isPublished': false},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        logger.d('Product unpublished successfully');
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      throw Exception('Failed to unpublish product');
    }
  }

  /// Update product stock
  Future<Product> updateProductStock(String productId, int newStock) async {
    logger.d('Updating product stock: $productId to $newStock');

    final response = await _apiClient.patch(
      '${ApiEndpoints.products}/$productId',
      data: {'countInStock': newStock},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        logger.d('Product stock updated successfully');
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      throw Exception('Failed to update product stock');
    }
  }

  /// Bulk update products
  Future<List<Product>> bulkUpdateProducts(
    List<Map<String, dynamic>> updates,
  ) async {
    logger.d('Bulk updating ${updates.length} products');

    final response = await _apiClient.patch(
      '${ApiEndpoints.products}/bulk',
      data: {'updates': updates},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['data'] is List) {
        logger.d('Products bulk updated successfully');
        return (data['data'] as List)
            .map<Product>((p) => Product.fromJson(p))
            .toList();
      } else {
        throw Exception('Unexpected API response structure');
      }
    } else {
      throw Exception('Failed to bulk update products');
    }
  }

  /// Search products
  Future<PaginatedData<Product>> searchProducts(
    String query, {
    int? limit,
    String? categoryId,
    String? vendorId,
  }) async {
    return fetchProducts(
      keyword: query,
      limit: limit,
      categoryId: categoryId,
      vendorId: vendorId,
    );
  }

  /// Upload media for a product
  Future<void> uploadMedia({
    required String productId,
    required List<String> filePaths,
    required String type,
  }) async {
    logger.d('Uploading media for product: $productId, type: $type');

    final formData = FormData.fromMap({
      'type': type,
      'reference': productId,
      'files': [
        for (var path in filePaths)
          await MultipartFile.fromFile(path, filename: path.split('/').last),
      ],
    });

    final response = await _apiClient.post(
      ApiEndpoints.uploadMultipleFiles,
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.d('Media uploaded successfully');
    } else {
      final errorMessage =
          response.data is Map && response.data['message'] != null
          ? response.data['message']
          : 'Failed to upload media';
      throw Exception(errorMessage);
    }
  }
}
