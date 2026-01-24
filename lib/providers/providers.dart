import 'package:bdoneapp/core/socket/socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/screens/auth/providers.dart';
import 'package:bdoneapp/core/utils/api_client.dart';
import 'package:bdoneapp/services/settings_service.dart';
import 'package:bdoneapp/services/terms_service.dart';
import 'package:bdoneapp/services/invoice_service.dart';
import 'package:bdoneapp/services/payment_service.dart';
import 'package:bdoneapp/services/quote_service.dart';
import 'package:bdoneapp/services/project_service.dart';
import 'package:bdoneapp/services/lead_project_service.dart';
import 'package:bdoneapp/services/product_service.dart';
import 'package:bdoneapp/services/service_service.dart';

/// Global ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.client;
});

final accessTokenProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return await repo.getAccessToken();
});

final socketServiceProvider = Provider<SocketService?>((ref) {
  final accessToken = ref.watch(accessTokenProvider).value;
  if (accessToken == null) return null;
  return SocketService(token: accessToken);
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final client = ref.watch(unauthenticatedApiClientProvider);
  return SettingsService(apiClient: client);
});

final termsServiceProvider = Provider<TermsService>((ref) {
  final client = ref.watch(unauthenticatedApiClientProvider);
  return TermsService(apiClient: client);
});



final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final client = ref.watch(apiClientProvider);
  return InvoiceService(apiClient: client);
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentService(apiClient: client);
});

final quoteServiceProvider = Provider<QuoteService>((ref) {
  final client = ref.watch(apiClientProvider);
  return QuoteService(apiClient: client);
});

final projectServiceProvider = Provider<ProjectService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProjectService(apiClient: client);
});

final leadProjectServiceProvider = Provider<LeadProjectService>((ref) {
  final client = ref.watch(apiClientProvider);
  return LeadProjectService(apiClient: client);
});

final productServiceProvider = Provider<ProductService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductService(apiClient: client);
});

final serviceServiceProvider = Provider<ServiceService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ServiceService(apiClient: client);
});



