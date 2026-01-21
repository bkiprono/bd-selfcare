// lib/providers/currency_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/services/currency_service.dart';
import 'package:bdcomputing/screens/auth/providers.dart';

// State for currency list management
class CurrencyListState {
  final List<Currency> currencies;
  final bool isLoading;
  final String? error;
  final DateTime? lastFetched;

  const CurrencyListState({
    this.currencies = const [],
    this.isLoading = false,
    this.error,
    this.lastFetched,
  });

  CurrencyListState copyWith({
    List<Currency>? currencies,
    bool? isLoading,
    String? error,
    DateTime? lastFetched,
  }) {
    return CurrencyListState(
      currencies: currencies ?? this.currencies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}

// Notifier for managing currency list state
class CurrencyListNotifier extends Notifier<CurrencyListState> {
  late final CurrencyService _service;
  static const Duration _cacheDuration = Duration(minutes: 30);

  @override
  CurrencyListState build() {
    _service = CurrencyService(apiClient: ref.read(unauthenticatedApiClientProvider));
    return const CurrencyListState();
  }

  Future<void> loadCurrencies({bool forceRefresh = false}) async {
    // Get current state safely
    final currentState = state;
    
    // Check if we have recent data and don't need to refresh
    if (!forceRefresh && 
        currentState.lastFetched != null && 
        DateTime.now().difference(currentState.lastFetched!) < _cacheDuration &&
        currentState.currencies.isNotEmpty) {
      return;
    }

    // Don't load if already loading
    if (currentState.isLoading) {
      return;
    }
    state = currentState.copyWith(isLoading: true, error: null);
    try {
      final currencies = await _service.fetchAllCurrencies();
      state = state.copyWith(
        currencies: currencies,
        isLoading: false,
        lastFetched: DateTime.now(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadCurrencies(forceRefresh: true);
  }

  List<Currency> get currencies => state.currencies;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
}

// Provider for currency service
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  return CurrencyService(apiClient: ref.watch(unauthenticatedApiClientProvider));
});

// Provider for currency list state
final currencyListProvider = NotifierProvider<CurrencyListNotifier, CurrencyListState>(() {
  return CurrencyListNotifier();
});

// Future provider for initial currency loading
final currenciesFutureProvider = FutureProvider<List<Currency>>((ref) async {
  final service = ref.watch(currencyServiceProvider);
  await service.loadSavedCurrency(); // Ensure saved currency is loaded first
  return await service.fetchAllCurrencies();
});

// Convenience provider for just the currencies list
final currenciesProvider = Provider<List<Currency>>((ref) {
  return ref.watch(currencyListProvider).currencies;
});

// Provider for loading state
final currenciesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(currencyListProvider).isLoading;
});

// Provider for error state
final currenciesErrorProvider = Provider<String?>((ref) {
  return ref.watch(currencyListProvider).error;
});