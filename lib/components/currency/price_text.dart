// lib/widgets/price_text.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/providers/price_provider.dart';

/// Production-ready price text widget with optimized rendering and caching
class PriceText extends ConsumerWidget {
  final double amount;
  final String? sourceCurrencyId;
  final TextStyle? style;
  final String? fallbackSymbol;
  final bool useMemoization;

  const PriceText({
    super.key,
    required this.amount,
    this.sourceCurrencyId,
    this.style,
    this.fallbackSymbol = '\$',
    this.useMemoization = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use memoized provider for better performance
    final provider = useMemoization ? memoizedPriceProvider : priceProvider;

    // Create args only once - memoized by Riverpod
    final args = PriceArgs(amount, sourceCurrencyId: sourceCurrencyId);
    final asyncPrice = ref.watch(provider(args));

    return asyncPrice.when(
      loading: () => _buildLoadingText(),
      error: (error, stack) => _buildErrorText(error),
      data: (price) => _buildPriceText(price),
    );
  }

  Widget _buildLoadingText() {
    return Text(_formatFallback(amount), style: _getLoadingStyle());
  }

  Widget _buildErrorText(Object error) {
    return Text(_formatFallback(amount), style: style ?? _getDefaultStyle());
  }

  Widget _buildPriceText(String price) {
    return Text(price, style: style ?? _getDefaultStyle());
  }

  TextStyle _getLoadingStyle() {
    return style?.copyWith(color: style?.color?.withValues(alpha: 0.6)) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        );
  }

  TextStyle _getDefaultStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  }

  String _formatFallback(double amount) {
    final symbol = fallbackSymbol ?? '\$';
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

/// Optimized price text widget for lists with automatic memoization
class OptimizedPriceText extends ConsumerWidget {
  final double amount;
  final String? sourceCurrencyId;
  final TextStyle? style;
  final String? fallbackSymbol;

  const OptimizedPriceText({
    super.key,
    required this.amount,
    this.sourceCurrencyId,
    this.style,
    this.fallbackSymbol = '\$',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always use memoization for list items
    final args = PriceArgs(amount, sourceCurrencyId: sourceCurrencyId);
    final asyncPrice = ref.watch(memoizedPriceProvider(args));

    return asyncPrice.when(
      loading: () => _buildSkeleton(),
      error: (_, _) => _buildFallback(),
      data: (price) => Text(price, style: style ?? _getDefaultStyle()),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 16,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFallback() {
    final symbol = fallbackSymbol ?? '\$';
    return Text(
      '$symbol${amount.toStringAsFixed(2)}',
      style: style ?? _getDefaultStyle(),
    );
  }

  TextStyle _getDefaultStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  }
}
