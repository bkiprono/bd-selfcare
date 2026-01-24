import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/components/currency/currency_picker.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/providers/currencies/selected_currency_provider.dart';
import 'package:bdoneapp/providers/currencies/currency_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bdoneapp/components/logger_config.dart';

class CurrencySelectorIcon extends ConsumerStatefulWidget {
  const CurrencySelectorIcon({super.key});

  @override
  ConsumerState<CurrencySelectorIcon> createState() =>
      _CurrencySelectorIconState();
}

class _CurrencySelectorIconState extends ConsumerState<CurrencySelectorIcon> {
  String _selectedCode = 'USD';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('currencyId');

    if (savedId != null) {
      // Try to get currency code from provider state
      final currenciesAsync = ref.read(currenciesFutureProvider);
      currenciesAsync.whenData((currencies) {
        final currency = currencies.firstWhere(
          (c) => c.id == savedId,
          orElse: () {
            logger.w('Currency not found for saved ID: $savedId, using USD');
            return currencies.firstWhere((c) => c.code == 'USD',
                orElse: () => currencies.first);
          },
        );
        if (mounted) {
          setState(() {
            _selectedCode = currency.code;
          });
        }
      });
    } else {
      // Default to USD if no currency is saved
      setState(() {
        _selectedCode = 'USD';
      });
    }
  }

  Future<void> _pickCurrency(BuildContext context) async {
    final selected = await CurrencyPickerBottomSheet.show(context);
    if (selected != null) {
      // Update provider state
      ref.read(selectedCurrencyProvider.notifier).setCurrency(selected.id);

      // Update local state
      setState(() {
        _selectedCode = selected.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedCurrencyId = ref.watch(selectedCurrencyProvider);
        final currenciesAsync = ref.watch(currenciesFutureProvider);

        return currenciesAsync.when(
          data: (currencies) {
            String displayCode = _selectedCode;

            // Get the current currency code from provider state
            if (selectedCurrencyId != null) {
              final currency = currencies.firstWhere(
                (c) => c.id == selectedCurrencyId,
                orElse: () {
                  logger.w(
                    'CurrencySelectionIcon: Currency not found for ID: $selectedCurrencyId',
                  );
                  return currencies.firstWhere((c) => c.code == _selectedCode,
                      orElse: () => currencies.first);
                },
              );
              displayCode = currency.code;
            }

            return SizedBox(
              height: 36,
              width: 60,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.secondaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  minimumSize: const Size(44, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _pickCurrency(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          displayCode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 1),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => SizedBox(
            height: 36,
            width: 60,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
          error: (error, stack) => SizedBox(
            height: 36,
            width: 60,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: const Size(44, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _pickCurrency(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'USD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 1),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
