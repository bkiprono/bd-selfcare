import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/models/common/currency.dart';
import 'package:bdoneapp/providers/currencies/currency_list_provider.dart';
import 'package:bdoneapp/services/currency_service.dart';

import 'package:bdoneapp/screens/auth/providers.dart';

class CurrencyNotifier extends Notifier<Currency?> {
  late final CurrencyService _service;

  @override
  Currency? build() {
    _service = CurrencyService(apiClient: ref.read(unauthenticatedApiClientProvider));
    _initialize();
    return null;
  }

  Future<void> _initialize() async {
    await _service.loadSavedCurrency();
    state = _service.currency;
  }

  Future<void> setCurrency(Currency currency) async {
    await _service.setCurrency(currency);
    state = _service.currency;
  }

  Future<void> setCurrencyById(String currencyId) async {
    final currenciesAsync = ref.read(currenciesFutureProvider);
    final currencies = currenciesAsync.when(
      data: (currencies) => currencies,
      loading: () => <Currency>[],
      error: (_, _) => <Currency>[],
    );

    if (currencies.isEmpty) {
      throw Exception('No currencies available');
    }

    final currency = currencies.firstWhere(
      (c) => c.id == currencyId,
      orElse: () => currencies.first,
    );
    await setCurrency(currency);
  }

  List<Currency> getCurrencies() {
    final currenciesAsync = ref.read(currenciesFutureProvider);
    return currenciesAsync.when(
      data: (currencies) => currencies,
      loading: () => <Currency>[],
      error: (_, _) => <Currency>[],
    );
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, Currency?>(() {
  return CurrencyNotifier();
});
