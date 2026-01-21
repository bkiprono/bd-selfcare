import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/providers/currencies/selected_currency_provider.dart';
import 'package:bdcomputing/providers/currencies/currency_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPickerBottomSheet extends ConsumerStatefulWidget {
  const CurrencyPickerBottomSheet({super.key});

  @override
  ConsumerState<CurrencyPickerBottomSheet> createState() =>
      _CurrencyPickerBottomSheetState();

  static Future<Currency?> show(BuildContext context) async {
    return await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CurrencyPickerBottomSheet(),
    );
  }
}

class _CurrencyPickerBottomSheetState
    extends ConsumerState<CurrencyPickerBottomSheet> {
  String? _selectedCurrencyId;
  String? _selectedCurrencyCode;
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _allCurrencies = [];
  List<Currency> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('currencyId');

    if (mounted) {
      setState(() {
        _selectedCurrencyId = savedId;
        _selectedCurrencyCode = null; // Will be set when currencies load
      });
    }
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = query.isEmpty
          ? List<Currency>.from(_allCurrencies)
          : _allCurrencies.where((currency) {
              return currency.code.toLowerCase().contains(query) ||
                  currency.name.toLowerCase().contains(query);
            }).toList();
    });
  }

  void _updateCurrencies(List<Currency> currencies) {
    if (mounted) {
      setState(() {
        _allCurrencies = List<Currency>.from(currencies);
        _filteredCurrencies = List<Currency>.from(currencies);

        // Set selected currency code if we have a selected ID
        if (_selectedCurrencyId != null) {
          try {
            final selectedCurrency = currencies.firstWhere(
              (c) => c.id == _selectedCurrencyId,
            );
            _selectedCurrencyCode = selectedCurrency.code;
          } catch (e) {
            // If selected currency not found, use base currency or first one
            if (currencies.isNotEmpty) {
              final baseCurrency = currencies.firstWhere(
                (c) => c.isBaseCurrency,
                orElse: () => currencies.first,
              );
              _selectedCurrencyCode = baseCurrency.code;
              _selectedCurrencyId = baseCurrency.id;
            }
          }
        } else {
          // No currency selected, use base currency
          if (currencies.isNotEmpty) {
            final baseCurrency = currencies.firstWhere(
              (c) => c.isBaseCurrency,
              orElse: () => currencies.first,
            );
            _selectedCurrencyCode = baseCurrency.code;
            _selectedCurrencyId = baseCurrency.id;
          }
        }
      });
    }
  }

  Future<void> _setSelectedCurrency(Currency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyId', currency.id);

    // update provider
    ref.read(selectedCurrencyProvider.notifier).setCurrency(currency.id);

    if (mounted) {
      setState(() {
        _selectedCurrencyId = currency.id;
        _selectedCurrencyCode = currency.code;
      });
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(currency);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Currency',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedCurrencyCode != null)
                          Text(
                            'Current: $_selectedCurrencyCode',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search currencies...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Currency list
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final currenciesAsync = ref.watch(currenciesFutureProvider);

                    return currenciesAsync.when(
                      data: (currencies) {
                        // Update local state when currencies are loaded
                        if (_allCurrencies.isEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _updateCurrencies(currencies);
                          });
                        }

                        if (_allCurrencies.isEmpty) {
                          return const Center(
                            child: Text('No currencies found'),
                          );
                        }

                        final filteredCurrencies = _filteredCurrencies;

                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: filteredCurrencies.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final currency = filteredCurrencies[index];
                            final isSelected =
                                currency.id == _selectedCurrencyId;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                child: Text(
                                  currency.code,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(currency.name),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () => _setSelectedCurrency(currency),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load currencies',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(currenciesFutureProvider);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
