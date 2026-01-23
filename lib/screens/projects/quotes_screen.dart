import 'package:bdcomputing/models/common/quote.dart';
import 'package:bdcomputing/screens/projects/quotes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class QuotesScreen extends ConsumerStatefulWidget {
  const QuotesScreen({super.key});

  @override
  ConsumerState<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quotesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quotes',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 18,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search quotes...',
                              hintStyle: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) {
                              ref.read(quotesProvider.notifier).setKeyword(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quote List
            Expanded(
              child: state.isLoading && state.quotes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.quotes.isEmpty
                      ? Center(child: Text(state.error!))
                      : RefreshIndicator(
                          onRefresh: () =>
                              ref.read(quotesProvider.notifier).refresh(),
                          child: state.quotes.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: state.quotes.length +
                                      (state.page <= state.totalPages ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == state.quotes.length) {
                                      ref
                                          .read(quotesProvider.notifier)
                                          .fetchQuotes();
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    final quote = state.quotes[index];
                                    return QuoteCard(quote: quote);
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedFileManagement,
            size: 64,
            color: Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Text(
            'No quotes found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class QuoteCard extends StatelessWidget {
  final Quote quote;

  const QuoteCard({super.key, required this.quote});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SENT':
        return const Color(0xFFFEF3C7);
      case 'ACCEPTED':
        return const Color(0xFFD1FAE5);
      case 'REJECTED':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'SENT':
        return const Color(0xFFD97706);
      case 'ACCEPTED':
        return const Color(0xFF059669);
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to quote detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              NumberFormat.currency(symbol: 'KES ')
                                  .format(quote.totalAmount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(quote.status),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                quote.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(quote.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quote.serial,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Valid until: ${DateFormat('MMM dd, yyyy').format(quote.validUntil)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20,
                    color: Color(0xFF999999),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
