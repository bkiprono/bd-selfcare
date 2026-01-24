import 'package:intl/intl.dart';
import 'package:bdoneapp/models/common/currency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/providers/currencies/currency_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PriceFormatter {
  final Ref _ref;
  PriceFormatter(this._ref);

  /// Converts and formats a price.
  ///
  /// [price] is the raw amount in the given [sourceCurrencyId].
  /// If [sourceCurrencyId] is not provided, assumes base currency.
  Future<String> transform(
    double price, {
    String? sourceCurrencyId,
    String? selectedCurrencyId,
  }) async {
    // Early return for zero or negative amounts
    if (price <= 0) {
      return _formatFallback(0);
    }
    
    final prefs = await SharedPreferences.getInstance();
    String? savedTargetId = prefs.getString('currencyId');

    // Get currencies from CurrencyService via Provider
    final currencyService = _ref.read(currencyServiceProvider);
    final supportedCurrencies = await currencyService.fetchAllCurrencies();

    if (supportedCurrencies.isEmpty) {
      return _formatFallback(price);
    }

    // --- Target currency (use selectedCurrencyId if provided, else saved, else fallback to USD) ---
    String? targetCurrencyId = selectedCurrencyId ?? savedTargetId;
    Currency targetCurrency;
    if (targetCurrencyId != null) {
      targetCurrency = supportedCurrencies.firstWhere(
        (c) => c.id == targetCurrencyId,
        orElse: () => supportedCurrencies.first,
      );
    } else {
      // fallback to USD if present, else first
      final usdCurrency = supportedCurrencies.where(
        (c) => c.code.toUpperCase() == 'USD',
      );
      if (usdCurrency.isNotEmpty) {
        targetCurrency = usdCurrency.first;
      } else {
        targetCurrency = supportedCurrencies.first;
      }
      // Save USD as default if nothing was stored
      await prefs.setString('currencyId', targetCurrency.id);
    }

    // --- Source currency (currency of the given price) ---
    Currency sourceCurrency;
    if (sourceCurrencyId != null) {
      sourceCurrency = supportedCurrencies.firstWhere(
        (c) => c.id == sourceCurrencyId,
        orElse: () => supportedCurrencies.first,
      );
    } else {
      // fallback to base currency if present, else first
      final baseCurrency = supportedCurrencies.where((c) => c.isBaseCurrency);
      if (baseCurrency.isNotEmpty) {
        sourceCurrency = baseCurrency.first;
      } else {
        sourceCurrency = supportedCurrencies.first;
      }
    }

    // --- Step 1: normalize to base currency ---
    final amountInBase = sourceCurrency.isBaseCurrency
        ? price
        : price /
            ((sourceCurrency.rateAgainstBaseCurrency == 0)
                ? 1
                : sourceCurrency.rateAgainstBaseCurrency);

    // --- Step 2: convert base → target currency ---
    final converted = targetCurrency.isBaseCurrency
        ? amountInBase
        : amountInBase *
            ((targetCurrency.rateAgainstBaseCurrency == 0)
                ? 1
                : targetCurrency.rateAgainstBaseCurrency);

    return _format(converted, code: targetCurrency.code);
  }

  /// Fallback formatting when currencies are not available
  String _formatFallback(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Format as "KES 1,200.00"
  String _format(double amount, {String code = 'USD'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_KE', // controls grouping separators
      symbol: '$code ', // prefix with currency code
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }
}