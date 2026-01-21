import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bdcomputing/providers/currencies/currency_list_provider.dart';
import 'package:bdcomputing/components/logger_config.dart';

/// Notifier to manage the selected currency ID
class SelectedCurrencyNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadCurrency();
    return null;
  }

  /// Load saved currency from SharedPreferences on init
  Future<void> _loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('currencyId');

      if (savedId != null && savedId.isNotEmpty) {
        state = savedId;
      } else {
        // No saved currency - set first available currency as default
        await _setDefaultCurrency();
      }
    } catch (e, s) {
      // If loading fails, try to set default currency
      logger.e('Failed to load currency', error: e, stackTrace: s);
      await _setDefaultCurrency();
    }
  }

  /// Set the first available currency as default
  Future<void> _setDefaultCurrency() async {
    try {
      // Load currencies if not already loaded
      final currencyListNotifier = ref.read(currencyListProvider.notifier);
      await currencyListNotifier.loadCurrencies();

      final currencies = ref.read(currencyListProvider).currencies;

      if (currencies.isNotEmpty) {
        final firstCurrency = currencies.first;
        logger.i(
          'Setting default currency: ${firstCurrency.code} (${firstCurrency.id})',
        );
        await setCurrency(firstCurrency.id);
      } else {
        logger.w('No currencies available to set as default');
        state = null;
      }
    } catch (e, s) {
      logger.e('Failed to set default currency', error: e, stackTrace: s);
      state = null;
    }
  }

  /// Update both state and SharedPreferences
  Future<void> setCurrency(String newCurrencyId) async {
    if (newCurrencyId.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currencyId', newCurrencyId);
      state = newCurrencyId;
    } catch (e, s) {
      logger.e('Failed to save currency', error: e, stackTrace: s);
      // Still update state even if saving fails
      state = newCurrencyId;
    }
  }

  /// Clear saved currency (useful for testing default behavior)
  Future<void> clearCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currencyId');
      state = null;
      // Automatically set default currency after clearing
      await _setDefaultCurrency();
    } catch (e, s) {
      logger.e('Failed to clear currency', error: e, stackTrace: s);
    }
  }
}

/// Provider for the current selected currency ID
final selectedCurrencyProvider =
    NotifierProvider<SelectedCurrencyNotifier, String?>(() {
      return SelectedCurrencyNotifier();
    });
