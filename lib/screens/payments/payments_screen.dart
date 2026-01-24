import 'package:bdoneapp/components/shared/header.dart';
import 'package:bdoneapp/core/navigation/adaptive_page_route.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/payments/payment.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/screens/common/pdf_viewer_screen.dart';
import 'package:bdoneapp/screens/payments/payments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
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

  void _showPaymentDetail(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentDetailSheet(
        payment: payment,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsProvider);
    final metrics = ref.watch(paymentMetricsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(
        title: 'Payments',
        showProfileIcon: true,
        showCurrencyIcon: false,
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Metrics (simplified from invoices_screen)
                  _buildMetricsOverview(metrics),

                  const SizedBox(height: 12),

                  // Search
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E5E5)),
                            borderRadius: BorderRadius.circular(8),
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
                                    hintText: 'Search payments...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (val) {
                                    ref
                                        .read(paymentsProvider.notifier)
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

            // Payment List
            Expanded(
              child: state.isLoading && state.payments.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.payments.isEmpty
                  ? Center(child: Text(state.error!))
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(paymentsProvider.notifier).refresh(),
                      child: state.payments.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount:
                                  state.payments.length +
                                  (state.page <= state.totalPages ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.payments.length) {
                                  ref
                                      .read(paymentsProvider.notifier)
                                      .fetchPayments();
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final payment = state.payments[index];
                                return PaymentCard(
                                  payment: payment,
                                  isExpanded:
                                      _expandedItems[payment.id] ?? false,
                                  onToggle: () => _toggleExpand(payment.id),
                                  onTap: () => _showPaymentDetail(payment),
                                );
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
            icon: HugeIcons.strokeRoundedCreditCardPos,
            size: 64,
            color: Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Text(
            'No payments found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview(Map<String, double> metrics) {
    final total = metrics['totalReceived'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          _buildMetricItem(
            'Total Paid',
            NumberFormat.currency(symbol: 'KES ').format(total),
            const Color(0xFF059669),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
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
          value,
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.isExpanded,
    required this.onToggle,
    required this.onTap,
  });

  String _getPaymentIcon(String channel) {
    switch (channel.toLowerCase()) {
      case 'mpesa':
        return 'assets/payments/mpesa.png';
      case 'pesapal':
        return 'assets/payments/pesapal.png';
      case 'cash':
        return 'assets/payments/cash.jpg';
      case 'cheque':
        return 'assets/payments/cheque.png';
      case 'bank_transfer':
      case 'bank transfer':
        return 'assets/payments/bank-transfer.png';
      case 'bank_deposit':
      case 'bank deposit':
        return 'assets/payments/direct-deposit.png';
      case 'airtel_money':
      case 'airtel money':
        return 'assets/payments/airtel-money.png';
      default:
        return 'assets/payments/cash.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border(
            top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
            left: BorderSide(color: Color(0xFFE5E5E5), width: 1),
            right: BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Payment icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        _getPaymentIcon(payment.paymentChannel),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                NumberFormat.currency(
                                  symbol: 'KES ',
                                ).format(payment.amountPaid),
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
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  payment.paymentChannel.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(payment.paymentDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
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
      
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailRow('REFERENCE NO', payment.reference),
                        const SizedBox(width: 12),
                        _buildDetailRow('RECEIPT NO', payment.receiptNumber),
                        const SizedBox(width: 12),
                        _buildDetailRow('SERIAL', payment.serial),
                      ],
                    ),
                    if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      _buildDetailRow('NOTES', payment.notes!),
                    ],
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

class PaymentDetailSheet extends ConsumerStatefulWidget {
  final Payment payment;
  final VoidCallback onClose;

  const PaymentDetailSheet({
    super.key,
    required this.payment,
    required this.onClose,
  });

  @override
  ConsumerState<PaymentDetailSheet> createState() => _PaymentDetailSheetState();
}

class _PaymentDetailSheetState extends ConsumerState<PaymentDetailSheet> {
  bool _isGeneratingPdf = false;
  Payment? _updatedPayment;

  Payment get currentPayment => _updatedPayment ?? widget.payment;

  Future<void> _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final updatedPayment = await paymentService.generateReceiptPdf(widget.payment.id);
      
      setState(() {
        _updatedPayment = updatedPayment;
        _isGeneratingPdf = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt generated successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingPdf = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate receipt: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                  'Payment Details',
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
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                      color: Color(0xFF059669),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    NumberFormat.currency(
                      symbol: 'KES ',
                    ).format(currentPayment.amountPaid),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentPayment.paymentChannel.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSheetRow(
                    'Transaction Date',
                    DateFormat(
                      'MMM dd, yyyy hh:mm a',
                    ).format(currentPayment.paymentDate),
                  ),
                  _buildDivider(),
                  _buildSheetRow('Reference ID', currentPayment.referenceId),
                  _buildDivider(),
                  _buildSheetRow('Receipt Number', currentPayment.receiptNumber),
                  _buildDivider(),
                  _buildSheetRow(
                    'Allocated',
                    NumberFormat.currency(
                      symbol: 'KES ',
                    ).format(currentPayment.allocatedAmount),
                  ),
                  _buildDivider(),
                  _buildSheetRow(
                    'Unallocated',
                    NumberFormat.currency(
                      symbol: 'KES ',
                    ).format(currentPayment.unAllocatedAmount),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPdf
                    ? null
                    : (currentPayment.receiptLink != null && currentPayment.receiptLink!.isNotEmpty
                        ? () {
                            Navigator.of(context).push(
                              AdaptivePageRoute(
                                builder: (context) => PdfViewerScreen(
                                  pdfUrl: currentPayment.receiptLink!,
                                  documentTitle: 'Receipt ${currentPayment.receiptNumber}',
                                  documentSerial: currentPayment.receiptNumber,
                                ),
                              ),
                            );
                          }
                        : _generatePdf),
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : HugeIcon(
                        icon: currentPayment.receiptLink != null && currentPayment.receiptLink!.isNotEmpty
                            ? HugeIcons.strokeRoundedFileView
                            : HugeIcons.strokeRoundedFileAdd,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isGeneratingPdf
                      ? 'Generating...'
                      : (currentPayment.receiptLink != null && currentPayment.receiptLink!.isNotEmpty
                          ? 'View Receipt'
                          : 'Generate Receipt'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isGeneratingPdf ? Colors.grey : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSheetRow(String label, String value) {
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

  Widget _buildDivider() => const Divider(color: Color(0xFFF3F4F6));
}
