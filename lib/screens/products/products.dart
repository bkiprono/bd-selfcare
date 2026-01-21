import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/screens/products/products_provider.dart';
import 'package:bdcomputing/components/currency/price_text.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/core/utils/debouncer.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String selectedStatus = 'Status';
  String selectedCategory = 'Category';
  final _debouncer = Debouncer(milliseconds: 500);
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).fetchProducts();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final products = productsState.products;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Header(
              title: 'Products',
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
                                hintText: 'Search products...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              onChanged: (value) {
                                _debouncer.run(() {
                                  ref
                                      .read(productsProvider.notifier)
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
                                    .read(productsProvider.notifier)
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
                        Navigator.of(context).pushNamed(AppRoutes.newProduct);
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
                  _buildLimitSelector(productsState.limit, (newLimit) {
                    ref.read(productsProvider.notifier).setLimit(newLimit);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Products list
            Expanded(
              child: productsState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : productsState.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Failed to load products',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(productsProvider.notifier)
                                  .fetchProducts(refresh: true);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(productsProvider.notifier)
                            .fetchProducts(refresh: true);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final imageUrl = product.images.isNotEmpty
                              ? product.images.first.link
                              : null;

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.viewProduct,
                                arguments: {'productId': product.id},
                              );
                            },
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imageUrl != null && imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => Icon(
                                                Icons.inventory_2_outlined,
                                                color: Colors.grey[300],
                                                size: 24,
                                              ),
                                            )
                                          : Icon(
                                              Icons.inventory_2_outlined,
                                              color: Colors.grey[300],
                                              size: 24,
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
                                                color: product.isPublished
                                                    ? AppColors.success
                                                    : Colors.grey[400],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              product.isPublished
                                                  ? 'Published'
                                                  : 'Draft',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: product.isPublished
                                                    ? AppColors.success
                                                    : Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            OptimizedPriceText(
                                              amount: product.sellingPrice,
                                              sourceCurrencyId: product.currencyId,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '•',
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${product.countInStock} in stock',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[300],
                                    size: 20,
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
            if (productsState.pages > 1)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${productsState.currentPage} of ${productsState.pages}',
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
                          isEnabled: productsState.currentPage > 1,
                          onPressed: () {
                            ref.read(productsProvider.notifier).prevPage();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPaginationButton(
                          icon: Icons.chevron_right,
                          isEnabled: productsState.currentPage < productsState.pages,
                          onPressed: () {
                            ref.read(productsProvider.notifier).nextPage();
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
      itemBuilder: (context) => [10, 20, 50, 100,1000,100000]
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
