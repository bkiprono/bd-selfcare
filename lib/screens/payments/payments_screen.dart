import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/models/payments/payment.dart';
import 'package:bdcomputing/screens/payments/payments_provider.dart';
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payments',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Overview Metrics (simplified from invoices_screen)
                  _buildMetricsOverview(metrics),
                  
                  const SizedBox(height: 24),
                  
                  // Search
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
                                    hintText: 'Search payments...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (val) {
                                    ref.read(paymentsProvider.notifier).setKeyword(val);
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
                          onRefresh: () => ref.read(paymentsProvider.notifier).refresh(),
                          child: state.payments.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: state.payments.length + (state.page <= state.totalPages ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == state.payments.length) {
                                      ref.read(paymentsProvider.notifier).fetchPayments();
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
                                      isExpanded: _expandedItems[payment.id] ?? false,
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
          const HugeIcon(icon: HugeIcons.strokeRoundedCreditCardPos, size: 64, color: Color(0xFFE5E7EB)),
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
            'Total Received',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              NumberFormat.currency(symbol: 'KES ').format(payment.amountPaid),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          DateFormat('MMM dd, yyyy • hh:mm a').format(payment.paymentDate),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
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
                  _buildDetailRow('REFERENCE NO', payment.reference),
                  const SizedBox(height: 12),
                  _buildDetailRow('RECEIPT NO', payment.receiptNumber),
                  const SizedBox(height: 12),
                  _buildDetailRow('SERIAL', payment.serial),
                  if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow('NOTES', payment.notes!),
                  ],
                ],
              ),
            ),
        ],
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
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Colors.black),
        ),
      ],
    );
  }
}

class PaymentDetailSheet extends StatelessWidget {
  final Payment payment;
  final VoidCallback onClose;

  const PaymentDetailSheet({
    super.key,
    required this.payment,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
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
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 20, color: Colors.black),
                  onPressed: onClose,
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
                    child: const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, color: Color(0xFF059669), size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    NumberFormat.currency(symbol: 'KES ').format(payment.amountPaid),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    payment.paymentChannel.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  _buildSheetRow('Transaction Date', DateFormat('MMM dd, yyyy hh:mm a').format(payment.paymentDate)),
                  _buildDivider(),
                  _buildSheetRow('Reference ID', payment.referenceId),
                  _buildDivider(),
                  _buildSheetRow('Receipt Number', payment.receiptNumber),
                  _buildDivider(),
                  _buildSheetRow('Allocated', NumberFormat.currency(symbol: 'KES ').format(payment.allocatedAmount)),
                  _buildDivider(),
                  _buildSheetRow('Unallocated', NumberFormat.currency(symbol: 'KES ').format(payment.unAllocatedAmount)),
                ],
              ),
            ),
          ),
          
          if (payment.receiptLink != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {}, // Link to open receipt
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload01, color: Colors.white, size: 20),
                  label: const Text('Download Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
