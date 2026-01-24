import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/common/base_transaction.dart';
import 'package:bdoneapp/screens/billing/invoices_provider.dart';
import 'package:bdoneapp/screens/payments/payments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

final combinedTransactionsProvider = Provider<List<BaseTransaction>>((ref) {
  final invoices = ref.watch(invoicesProvider).invoices;
  final payments = ref.watch(paymentsProvider).payments;

  final formatter = NumberFormat.currency(symbol: 'KES ');

  // Take latest 5 invoices
  final latestInvoices = invoices.take(5).map((inv) => BaseTransaction(
        id: inv.id,
        title: 'Invoice #${inv.serial}',
        subtitle: inv.client.name,
        date: inv.createdAt,
        amount: formatter.format(inv.totalAmount),
        status: inv.status.toUpperCase(),
        statusColor: _getInvoiceStatusColor(inv.status),
        type: TransactionType.invoice,
        icon: HugeIcons.strokeRoundedFile02,
        originalData: inv,
      ));

  // Take latest 5 payments
  final latestPayments = payments.take(5).map((p) => BaseTransaction(
        id: p.id,
        title: 'Payment received',
        subtitle: p.paymentChannel.toUpperCase(),
        date: p.paymentDate,
        amount: formatter.format(p.amountPaid),
        status: 'PAID',
        statusColor: AppColors.secondary,
        type: TransactionType.payment,
        icon: HugeIcons.strokeRoundedWallet01,
        originalData: p,
      ));

  // Combine and sort by date descending
  final combined = [...latestInvoices, ...latestPayments];
  combined.sort((a, b) => b.date.compareTo(a.date));

  return combined;
});

dynamic _getInvoiceStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PAID':
    case 'FULLY_PAID':
      return AppColors.secondary;
    case 'PENDING':
    case 'PARTIALLY_PAID':
      return AppColors.warning;
    case 'CANCELLED':
      return AppColors.error;
    default:
      return AppColors.primary;
  }
}
