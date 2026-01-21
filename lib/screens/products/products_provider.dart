import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:bdcomputing/components/logger_config.dart';
import 'package:bdcomputing/models/products/manage_product.dart';
import 'package:bdcomputing/models/products/product.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/repositories/product_repository.dart';
class ProductsState {
  final bool isLoading;
  final List<Product> products;
  final String? error;
  final bool isFiltering;
  final int currentPage;
  final int limit;
  final int total;
  final int pages;
  final String keyword;

  const ProductsState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.isFiltering = false,
    this.currentPage = 1,
    this.limit = 10,
    this.total = 0,
    this.pages = 0,
    this.keyword = '',
  });

  ProductsState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
    bool? isFiltering,
    int? currentPage,
    int? limit,
    int? total,
    int? pages,
    String? keyword,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
      isFiltering: isFiltering ?? this.isFiltering,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      pages: pages ?? this.pages,
      keyword: keyword ?? this.keyword,
    );
  }
}

class ProductsController extends StateNotifier<ProductsState> {
  final ProductRepository _repository;
  final Ref _ref;

  ProductsController(this._repository, this._ref) : super(const ProductsState());

  Future<void> fetchProducts({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final paginatedData = await _repository.fetchProducts(
        limit: state.limit,
        page: state.currentPage,
        keyword: state.keyword,
      );
      
      state = state.copyWith(
        isLoading: false,
        products: paginatedData.data,
        total: paginatedData.total,
        pages: paginatedData.pages,
        currentPage: paginatedData.page,
        limit: paginatedData.limit,
        error: null,
      );
    } catch (e, stack) {
      logger.e('Failed to fetch products', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setKeyword(String keyword) {
    if (state.keyword == keyword) return;
    state = state.copyWith(keyword: keyword, currentPage: 1);
    fetchProducts(refresh: true);
  }

  void setPage(int page) {
    if (state.currentPage == page) return;
    state = state.copyWith(currentPage: page);
    fetchProducts(refresh: true);
  }

  void nextPage() {
    if (state.currentPage < state.pages) {
      setPage(state.currentPage + 1);
    }
  }

  void prevPage() {
    if (state.currentPage > 1) {
      setPage(state.currentPage - 1);
    }
  }

  void setLimit(int limit) {
    if (state.limit == limit) return;
    state = state.copyWith(limit: limit, currentPage: 1);
    fetchProducts(refresh: true);
  }

  Future<void> filterProducts({
    String? status, 
    String? categoryId,
    String? query,
  }) async {
      // Implement filtering logic here if needed, or trigger a new fetch with params
      // For now, let's just re-fetch with params if the repository supports it
      // Since repository wrapper might not expose all params, we might need to update repository or use service directly
      // But based on current simple requirement, we just load all.
      
      // NOTE: This is a placeholder for future detailed filtering implementation
      fetchProducts(refresh: true);
  }

  Future<bool> createProduct(CreateProductModel product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createProduct(product);
      await fetchProducts(refresh: true);
      return true;
    } catch (e, stack) {
      logger.e('Failed to create product', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(String productId, CreateProductModel product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateProduct(productId, product);
      _ref.invalidate(productDetailsProvider(productId));
      await fetchProducts(refresh: true);
      return true;
    } catch (e, stack) {
      logger.e('Failed to update product', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> uploadProductMedia({
    required String productId,
    required List<String> filePaths,
    required String type,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.uploadMedia(productId, filePaths, type);
      _ref.invalidate(productDetailsProvider(productId));
      await fetchProducts(refresh: true);
      return true;
    } catch (e, stack) {
      logger.e('Failed to upload media', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final productsProvider = StateNotifierProvider<ProductsController, ProductsState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductsController(repository, ref);
});

final productDetailsProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});
