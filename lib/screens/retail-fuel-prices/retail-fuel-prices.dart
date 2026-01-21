import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/models/fuel/fuel_price.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/components/currency/price_text.dart';
import 'package:bdcomputing/providers/retail_fuel_prices_provider.dart';
import 'package:bdcomputing/screens/retail-fuel-prices/add_edit_retail_fuel_price_screen.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:bdcomputing/core/utils/debouncer.dart';

class RetailFuelPricesScreen extends ConsumerStatefulWidget {
  const RetailFuelPricesScreen({super.key});

  @override
  ConsumerState<RetailFuelPricesScreen> createState() =>
      _RetailFuelPricesScreenState();
}

class _RetailFuelPricesScreenState
    extends ConsumerState<RetailFuelPricesScreen> {
  String selectedStatus = 'Status';
  String selectedCategory = 'Category';
  final _debouncer = Debouncer(milliseconds: 500);
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(retailFuelPricesProvider.notifier).fetchFuelPrices();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddEdit({FuelPrice? fuelPrice}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRetailFuelPriceScreen(
          fuelPrice: fuelPrice,
          existingPrices: ref.read(retailFuelPricesProvider).fuelPrices,
        ),
      ),
    );

    if (result == true) {
      ref.read(retailFuelPricesProvider.notifier).fetchFuelPrices(refresh: true);
    }
  }

  Future<void> _toggleStatus(FuelPrice price, bool value) async {
    try {
      final fuelService = ref.read(fuelServiceProvider);
      await fuelService.updateRetailFuelPriceSupplyStatus(
        id: price.id,
        active: value,
      );
      ref.read(retailFuelPricesProvider.notifier).fetchFuelPrices(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuelState = ref.watch(retailFuelPricesProvider);
    final fuelPrices = fuelState.fuelPrices;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Header(
              title: 'Retail Fuel Prices',
              showBackButton: false,
              centerTitle: false,
              showProfileIcon: true,
              showCurrencyIcon: true,
            ),

            // Search and filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search fuel prices...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              onChanged: (value) {
                                _debouncer.run(() {
                                  ref
                                      .read(retailFuelPricesProvider.notifier)
                                      .setKeyword(value);
                                });
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(retailFuelPricesProvider.notifier)
                                    .setKeyword('');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.newFuelPrice);
                      },
                      icon: const Icon(Icons.add),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter dropdowns
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildDropdownFilter(selectedStatus, () {
                    // Implement status filter logic
                  }),
                  const SizedBox(width: 12),
                  _buildDropdownFilter(selectedCategory, () {
                    // Implement category filter logic
                  }),
                  const Spacer(),
                  // Limit selector
                  _buildLimitSelector(fuelState.limit, (newLimit) {
                    ref.read(retailFuelPricesProvider.notifier).setLimit(newLimit);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prices list
            Expanded(
              child: fuelState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : fuelState.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Failed to load retail fuel prices',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(retailFuelPricesProvider.notifier)
                                  .fetchFuelPrices(refresh: true);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : fuelPrices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedPetrolPump,
                            size: 64,
                            color: Colors.grey[200]!,
                          ),
                          const SizedBox(height: 16),
                          const Text('No retail fuel configured'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(retailFuelPricesProvider.notifier)
                            .fetchFuelPrices(refresh: true);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: fuelPrices.length,
                        itemBuilder: (context, index) {
                          final price = fuelPrices[index];

                          return InkWell(
                            onTap: () => _navigateToAddEdit(fuelPrice: price),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: Colors.grey[100]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedPetrolPump,
                                        size: 30,
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: price.supplyActive
                                                    ? AppColors.success
                                                    : Colors.grey[400],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              price.supplyActive
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: price.supplyActive
                                                    ? AppColors.success
                                                    : Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${price.fuelProduct?.name ?? 'Unknown'} - ${price.fuelProductType?.name ?? 'Unknown'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        OptimizedPriceText(
                                          amount: price.price,
                                          sourceCurrencyId: price.currencyId,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: price.supplyActive,
                                    onChanged: (val) => _toggleStatus(price, val),
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: AppColors.success,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            // Pagination Controls
            if (fuelState.pages > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${fuelState.currentPage} of ${fuelState.pages}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        _buildPaginationButton(
                          icon: Icons.chevron_left,
                          isEnabled: fuelState.currentPage > 1,
                          onPressed: () {
                            ref.read(retailFuelPricesProvider.notifier).prevPage();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPaginationButton(
                          icon: Icons.chevron_right,
                          isEnabled: fuelState.currentPage < fuelState.pages,
                          onPressed: () {
                            ref.read(retailFuelPricesProvider.notifier).nextPage();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitSelector(int currentLimit, Function(int) onSelected) {
    return PopupMenuButton<int>(
      initialValue: currentLimit,
      onSelected: onSelected,
      itemBuilder: (context) => [10, 20, 50, 100, 1000, 100000]
          .map((limit) => PopupMenuItem(
                value: limit,
                child: Text('$limit per page'),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$currentLimit/page',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled ? Colors.grey[300]! : Colors.grey[100]!,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: isEnabled ? onPressed : null,
        color: isEnabled ? AppColors.textPrimary : Colors.grey[300],
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
