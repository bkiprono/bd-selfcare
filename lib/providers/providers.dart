import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/models/products/product_category.dart';
import 'package:bdcomputing/services/products_service.dart';
import 'package:bdcomputing/repositories/product_repository.dart';
import 'package:bdcomputing/services/fuel_service.dart';
import 'package:bdcomputing/services/orders_service.dart';
import 'package:bdcomputing/services/product_categories_service.dart';
import 'package:bdcomputing/repositories/product_category_repository.dart';
import 'package:bdcomputing/services/settings_service.dart';
import 'package:bdcomputing/services/terms_service.dart';
import 'package:bdcomputing/services/invoice_service.dart';
import 'package:bdcomputing/services/payment_service.dart';
import 'package:bdcomputing/repositories/orders_repository.dart';

/// Global ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.client;
});

final productServiceProvider = Provider<ProductService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductService(apiClient: client);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final service = ref.watch(productServiceProvider);
  return ProductRepository(service: service);
});

final fuelServiceProvider = Provider<FuelService>((ref) {
  final client = ref.watch(apiClientProvider);
  return FuelService(apiClient: client);
});

final ordersServiceProvider = Provider<OrdersService>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrdersService(apiClient: client);
});

final productCategoriesProvider = Provider<ProductCategoriesService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductCategoriesService(apiClient: client);
});

final productCategoryRepositoryProvider = Provider<ProductCategoryRepository>((ref) {
  final service = ref.watch(productCategoriesProvider);
  return ProductCategoryRepository(service: service);
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final client = ref.watch(unauthenticatedApiClientProvider);
  return SettingsService(apiClient: client);
});

final termsServiceProvider = Provider<TermsService>((ref) {
  final client = ref.watch(unauthenticatedApiClientProvider);
  return TermsService(apiClient: client);
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrdersRepository(client: client);
});

final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final client = ref.watch(apiClientProvider);
  return InvoiceService(apiClient: client);
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentService(apiClient: client);
});

// FutureProvider for fetching product categories
final productCategoriesListProvider = FutureProvider<List<ProductCategory>>((ref) async {
  final repository = ref.watch(productCategoryRepositoryProvider);
  return await repository.getAllProducts();
});


