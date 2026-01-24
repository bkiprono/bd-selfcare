// lib/providers/price_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/core/pipes/price_formatter.dart';
import 'package:bdoneapp/providers/currencies/selected_currency_provider.dart';
import 'package:bdoneapp/providers/currencies/currency_list_provider.dart';

/// Cached price formatter to avoid recreating on every call
final _priceFormatterProvider = Provider<PriceFormatter>((ref) {
  return PriceFormatter(ref);
});

/// Cached price cache to avoid recalculating same prices
final _priceCacheProvider = Provider<Map<String, String>>((ref) {
  return <String, String>{};
});

/// Provides a formatted price string based on amount + source currency.
/// Optimized for production with proper caching and memoization.
final priceProvider = FutureProvider.family<String, PriceArgs>((
  ref,
  args,
) async {
  // Only watch selectedCurrencyProvider - no need for explicit watching in widget
  final selectedCurrencyId = ref.watch(selectedCurrencyProvider);

  // Use cached formatter
  final formatter = ref.watch(_priceFormatterProvider);

  return await formatter.transform(
    args.amount,
    sourceCurrencyId: args.sourceCurrencyId,
    selectedCurrencyId: selectedCurrencyId,
  );
});

/// Memoized price provider that caches results based on amount and currency
final memoizedPriceProvider = FutureProvider.family<String, PriceArgs>((
  ref,
  args,
) async {
  final selectedCurrencyId = ref.watch(selectedCurrencyProvider);

  // Create cache key for this specific price calculation
  final cacheKey =
      '${args.amount}_${args.sourceCurrencyId}_$selectedCurrencyId';
  final cache = ref.watch(_priceCacheProvider);

  // Check cache first
  if (cache.containsKey(cacheKey)) {
    return cache[cacheKey]!;
  }

  final currenciesAsync = ref.watch(currenciesFutureProvider);

  // Wait for currencies to be available with timeout
  final currencies = await currenciesAsync.when(
    data: (currencies) async => currencies,
    loading: () async {
      // Wait a bit for currencies to load
      await Future.delayed(const Duration(milliseconds: 200));
      final retryAsync = ref.read(currenciesFutureProvider);
      return retryAsync.when(
        data: (currencies) => currencies,
        loading: () => <dynamic>[],
        error: (_, _) => <dynamic>[],
      );
    },
    error: (_, _) async => <dynamic>[],
  );

  if (currencies.isEmpty) {
    // Return fallback format if currencies not available
    final fallback = '\$${args.amount.toStringAsFixed(2)}';
    cache[cacheKey] = fallback;
    return fallback;
  }

  final formatter = ref.watch(_priceFormatterProvider);
  final result = await formatter.transform(
    args.amount,
    sourceCurrencyId: args.sourceCurrencyId,
    selectedCurrencyId: selectedCurrencyId,
  );

  // Cache the result
  cache[cacheKey] = result;
  return result;
});

/// Helper class for arguments with proper equality
class PriceArgs {
  final double amount;
  final String? sourceCurrencyId;

  const PriceArgs(this.amount, {this.sourceCurrencyId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PriceArgs &&
        other.amount == amount &&
        other.sourceCurrencyId == sourceCurrencyId;
  }

  @override
  int get hashCode => Object.hash(amount, sourceCurrencyId);
}
