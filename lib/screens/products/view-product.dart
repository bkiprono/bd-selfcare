import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/components/currency/price_text.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/enums/product_enums.dart';
import 'package:bdcomputing/screens/products/products_provider.dart';
import 'package:bdcomputing/screens/products/widgets/product_image_gallery.dart';
import 'package:bdcomputing/screens/products/widgets/upload_media_sheet.dart';

class ViewProductScreen extends ConsumerWidget {
  final String productId;

  const ViewProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Header(title: 'Product Details', showCurrencyIcon: false),
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productDetailsProvider(productId));
              await ref.read(productDetailsProvider(productId).future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  ProductImageGallery(
                    images: product.images,
                    productId: product.id,
                  ),
                  const SizedBox(height: 20),

                  // Basic Info Card
                  _buildSectionCard(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildStatusChip(
                                label: product.isPublished
                                    ? 'Published'
                                    : 'Draft',
                                color: product.isPublished
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              _buildStatusChip(
                                label:
                                    product.approvalStatus.name[0]
                                        .toUpperCase() +
                                    product.approvalStatus.name
                                        .substring(1)
                                        .toLowerCase(),
                                color: _getApprovalColor(
                                  product.approvalStatus,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            product.subCategory?.name ?? 'Uncategorized',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating} (${product.numOfReviews} reviews)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pricing Card
                  _buildSectionCard(
                    title: 'Pricing Breakdown',
                    children: [
                      _buildPricingRow(
                        'Unit Price',
                        product.unitPrice,
                        product.currencyId,
                      ),
                      const SizedBox(height: 8),
                      _buildPricingRow(
                        'Markup',
                        product.markupPrice,
                        product.currencyId,
                        isPositive: true,
                      ),
                      const SizedBox(height: 8),
                      _buildPricingRow(
                        'Discount',
                        -product.discountedPrice,
                        product.currencyId,
                        isNegative: true,
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Selling Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          OptimizedPriceText(
                            amount: product.sellingPrice,
                            sourceCurrencyId: product.currencyId,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Card
                  if (product.description.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Description',
                      children: [
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Shipping & Logistics Card
                  _buildSectionCard(
                    title: 'Shipping & Logistics',
                    children: [
                      _buildInfoRow(
                        'Shipping Days',
                        '${product.shippingDays} days',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Delivery Days',
                        '${product.deliveryDays} days',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Pickup Days',
                        '${product.pickupDays} days',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Return Policy',
                        '${product.freeReturnDays} days',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Free Shipping',
                        product.freeShipping ? 'Yes' : 'No',
                        valueColor: product.freeShipping
                            ? Colors.green
                            : AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Specifications Card
                  _buildSectionCard(
                    title: 'Specifications',
                    children: [
                      _buildInfoRow(
                        'Category',
                        product.category?.name ?? 'Unknown',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Subcategory',
                        product.subCategory?.name ?? 'None',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Country', product.countryOfOrigin.name),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Weight',
                        '${product.weight} ${product.weightUnit}',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Min Order', '${product.minOrderCount}'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Min Stock Alert',
                        '${product.minStockAlert} units',
                        valueColor: product.countInStock > product.minStockAlert
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Current Stock',
                        '${product.countInStock} units',
                        valueColor: product.countInStock > product.minStockAlert
                            ? Colors.green
                            : Colors.red,
                      ),
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => UploadMediaSheet(
                                productId: product.id,
                                mediaType: 'product-specification',
                                title: 'Upload Specifications',
                                allowedExtensions: const ['pdf', 'doc', 'docx'],
                              ),
                            );
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Documents'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load product',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(productDetailsProvider(productId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: productAsync.when(
        data: (product) => product != null
            ? FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.newProduct,
                    arguments: {'productId': product.id},
                  );
                  if (result == true) {
                    ref.invalidate(productDetailsProvider(productId));
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.edit, color: Colors.white),
              )
            : null,
        loading: () => null,
        error: (error, stack) => null,
      ),
    );
  }

  Widget _buildSectionCard({String? title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingRow(
    String label,
    double amount,
    String currencyId, {
    bool isPositive = false,
    bool isNegative = false,
  }) {
    Color amountColor = AppColors.textPrimary;
    if (isPositive) amountColor = Colors.green;
    if (isNegative) amountColor = Colors.red;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        OptimizedPriceText(
          amount: amount,
          sourceCurrencyId: currencyId,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Color _getApprovalColor(ProductApprovalStatus status) {
    switch (status) {
      case ProductApprovalStatus.approved:
        return Colors.green;
      case ProductApprovalStatus.pending:
        return Colors.orange;
      case ProductApprovalStatus.rejected:
        return Colors.red;
    }
  }
}
