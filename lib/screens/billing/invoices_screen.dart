import 'package:bdoneapp/components/shared/header.dart';
import 'package:bdoneapp/core/navigation/adaptive_page_route.dart';
import 'package:bdoneapp/models/common/invoice.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/screens/billing/invoices_provider.dart';
import 'package:bdoneapp/screens/common/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final Map<String, bool> _expandedItems = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String id) {
    setState(() {
      _expandedItems[id] = !(_expandedItems[id] ?? false);
    });
  }

  void _showInvoiceDetail(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceDetailSheet(
        invoice: invoice,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoicesProvider);
    final metrics = ref.watch(invoiceMetricsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(
        title: 'Invoices',
        showProfileIcon: true,
        showCurrencyIcon: false,
        actions: [],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics Summary
                _buildMetricsSummary(metrics),
                const SizedBox(height: 8),

                // Search & Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                                  hintText: 'Search invoices...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (val) {
                                  ref
                                      .read(invoicesProvider.notifier)
                                      .setKeyword(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Invoice List
          Expanded(
            child: state.isLoading && state.invoices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.invoices.isEmpty
                ? Center(child: Text(state.error!))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(invoicesProvider.notifier).refresh(),
                    child: state.invoices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount:
                                state.invoices.length +
                                (state.page <= state.totalPages ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.invoices.length) {
                                ref
                                    .read(invoicesProvider.notifier)
                                    .fetchInvoices();
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final invoice = state.invoices[index];
                              return InvoiceCard(
                                invoice: invoice,
                                isExpanded: _expandedItems[invoice.id] ?? false,
                                onToggle: () => _toggleExpand(invoice.id),
                                onTap: () => _showInvoiceDetail(invoice),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedInvoice01,
            size: 64,
            color: Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Text(
            'No invoices found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSummary(Map<String, double> metrics) {
    final total = metrics['totalInvoiced'] ?? 0;
    final due = metrics['totalDue'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          _buildMetricItem('Total Invoiced', total, Colors.black),
          const SizedBox(width: 24),
          _buildMetricItem('Total Due', due, const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: 'KES ').format(value),
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.isExpanded,
    required this.onToggle,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFFD1FAE5);
      case 'partially paid':
        return const Color(0xFFFEF3C7);
      case 'unpaid':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF059669);
      case 'partially paid':
        return const Color(0xFFD97706);
      case 'unpaid':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                NumberFormat.currency(
                                  symbol: 'KES ',
                                ).format(invoice.totalAmount),
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
                                  color: _getStatusColor(invoice.status),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  invoice.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusTextColor(invoice.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invoice.serial,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedMoreVertical,
                      size: 20,
                      color: Color(0xFF999999),
                    ),
                    IconButton(
                      icon: HugeIcon(
                        icon: isExpanded
                            ? HugeIcons.strokeRoundedArrowUp01
                            : HugeIcons.strokeRoundedArrowDown01,
                        size: 20,
                        color: const Color(0xFF999999),
                      ),
                      onPressed: onToggle,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailRow(
                      'DUE DATE',
                      DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                    ),
                    const SizedBox(width: 12),
                    _buildDetailRow(
                      'AMOUNT DUE',
                      NumberFormat.currency(
                        symbol: 'KES ',
                      ).format(invoice.amountDue),
                    ),
                    const SizedBox(width: 12),
                    _buildDetailRow(
                      'CREATED AT',
                      DateFormat('MMM dd, yyyy').format(invoice.createdAt),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF666666),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, color: Colors.black)),
      ],
    );
  }
}

class InvoiceDetailSheet extends ConsumerStatefulWidget {
  final Invoice invoice;
  final VoidCallback onClose;

  const InvoiceDetailSheet({
    super.key,
    required this.invoice,
    required this.onClose,
  });

  @override
  ConsumerState<InvoiceDetailSheet> createState() => _InvoiceDetailSheetState();
}

class _InvoiceDetailSheetState extends ConsumerState<InvoiceDetailSheet> {
  bool _isGeneratingPdf = false;
  Invoice? _updatedInvoice;

  Invoice get currentInvoice => _updatedInvoice ?? widget.invoice;

  Future<void> _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final updatedInvoice = await invoiceService.generateInvoicePdf(
        widget.invoice.id,
      );

      setState(() {
        _updatedInvoice = updatedInvoice;
        _isGeneratingPdf = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingPdf = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 20,
                    color: Colors.black,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedInvoice01,
                      color: Color(0xFF2563EB),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    NumberFormat.currency(
                      symbol: 'KES ',
                    ).format(widget.invoice.totalAmount),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No. ${widget.invoice.serial}',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Summary Cards
                  _buildInfoSection(
                    'Status',
                    widget.invoice.status.toUpperCase(),
                  ),
                  _buildInfoSection(
                    'Due Date',
                    DateFormat('MMM dd, yyyy').format(widget.invoice.dueDate),
                  ),
                  _buildInfoSection(
                    'Total Amount',
                    NumberFormat.currency(
                      symbol: 'KES ',
                    ).format(widget.invoice.totalAmount),
                  ),
                  _buildInfoSection(
                    'Amount Paid',
                    NumberFormat.currency(
                      symbol: 'KES ',
                    ).format(widget.invoice.amountPaid),
                  ),
                  _buildInfoSection(
                    'Amount Due',
                    NumberFormat.currency(
                      symbol: 'KES ',
                    ).format(widget.invoice.amountDue),
                  ),

                  if (widget.invoice.notes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Notes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.invoice.notes,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGeneratingPdf
                        ? null
                        : (currentInvoice.invoiceLink.isNotEmpty
                              ? () {
                                  Navigator.of(context).push(
                                  AdaptivePageRoute(
                                    builder: (context) => PdfViewerScreen(
                                      pdfUrl: currentInvoice.invoiceLink,
                                      documentTitle:
                                          'Invoice ${currentInvoice.serial}',
                                      documentSerial: currentInvoice.serial,
                                    ),
                                  ),
                                  );
                                }
                              : _generatePdf),
                    icon: _isGeneratingPdf
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : HugeIcon(
                            icon: currentInvoice.invoiceLink.isNotEmpty
                                ? HugeIcons.strokeRoundedFileView
                                : HugeIcons.strokeRoundedFileAdd,
                            size: 18,
                            color: _isGeneratingPdf
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF374151),
                          ),
                    label: Text(
                      _isGeneratingPdf
                          ? 'Generating...'
                          : (currentInvoice.invoiceLink.isNotEmpty
                                ? 'View PDF'
                                : 'Generate PDF'),
                      style: TextStyle(
                        color: _isGeneratingPdf
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF374151),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: _isGeneratingPdf
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFFD1D5DB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentInvoice.amountDue > 0
                        ? () {
                            Navigator.of(context).pushNamed(
                              '/payment',
                              arguments: {'invoiceId': currentInvoice.id},
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF666666))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
