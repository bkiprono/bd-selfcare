import 'package:bdcomputing/models/common/client.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/models/common/invoice.dart';
import 'package:bdcomputing/models/payments/payment_allocation.dart';
import 'package:bdcomputing/models/payments/payment_channels.dart';

class Payment {
  final String id;
  final String serial;
  final String? clientId;
  final String? invoiceId;
  final String? accountNumber;
  final String currencyId;
  final String paymentChannel;
  final double amountPaid;
  final double allocatedAmount;
  final double unAllocatedAmount;
  final String referenceId;
  final String reference;
  final DateTime paymentDate;
  final String? receiptLink;
  final String receiptNumber;
  final double balance;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? updatedBy;
  final String? deletedBy;
  final DateTime? deletedAt;

  // Relations
  final Client? client;
  final Invoice? invoice;
  final Currency? currency;
  final CashPayment? cash;
  final ManualMpesaPayment? mpesaManual;
  final ChequePayment? cheque;
  final MpesaTransaction? mpesa;
  final BankTransferPayment? bankTransfer;
  final BankDepositPayment? bankDeposit;
  final List<PaymentAllocation>? allocations;

  Payment({
    required this.id,
    required this.serial,
    this.clientId,
    this.invoiceId,
    this.accountNumber,
    required this.currencyId,
    required this.paymentChannel,
    required this.amountPaid,
    required this.allocatedAmount,
    required this.unAllocatedAmount,
    required this.referenceId,
    required this.reference,
    required this.paymentDate,
    this.receiptLink,
    required this.receiptNumber,
    required this.balance,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.updatedBy,
    this.deletedBy,
    this.deletedAt,
    this.client,
    this.invoice,
    this.currency,
    this.cash,
    this.mpesaManual,
    this.cheque,
    this.mpesa,
    this.bankTransfer,
    this.bankDeposit,
    this.allocations,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      serial: (json['serial'] ?? '').toString(),
      clientId: json['clientId']?.toString(),
      invoiceId: json['invoiceId']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      currencyId: (json['currencyId'] ?? '').toString(),
      paymentChannel: (json['paymentChannel'] ?? '').toString(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      allocatedAmount: (json['allocatedAmount'] ?? 0).toDouble(),
      unAllocatedAmount: (json['unAllocatedAmount'] ?? 0).toDouble(),
      referenceId: (json['referenceId'] ?? '').toString(),
      reference: (json['reference'] ?? '').toString(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      receiptLink: json['receiptLink']?.toString(),
      receiptNumber: (json['receiptNumber'] ?? '').toString(),
      balance: (json['balance'] ?? 0).toDouble(),
      notes: json['notes']?.toString(),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      updatedBy: json['updatedBy']?.toString(),
      deletedBy: json['deletedBy']?.toString(),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      invoice: json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null,
      currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
      cash: json['cash'] != null ? CashPayment.fromJson(json['cash']) : null,
      mpesaManual: json['mpesa_manual'] != null ? ManualMpesaPayment.fromJson(json['mpesa_manual']) : null,
      cheque: json['cheque'] != null ? ChequePayment.fromJson(json['cheque']) : null,
      mpesa: json['mpesa'] != null ? MpesaTransaction.fromJson(json['mpesa']) : null,
      bankTransfer: json['bank_transfer'] != null ? BankTransferPayment.fromJson(json['bank_transfer']) : null,
      bankDeposit: json['bank_deposit'] != null ? BankDepositPayment.fromJson(json['bank_deposit']) : null,
      allocations: (json['allocations'] as List? ?? [])
          .map((e) => PaymentAllocation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial': serial,
      'clientId': clientId,
      'invoiceId': invoiceId,
      'accountNumber': accountNumber,
      'currencyId': currencyId,
      'paymentChannel': paymentChannel,
      'amountPaid': amountPaid,
      'allocatedAmount': allocatedAmount,
      'unAllocatedAmount': unAllocatedAmount,
      'referenceId': referenceId,
      'reference': reference,
      'paymentDate': paymentDate.toIso8601String(),
      'receiptLink': receiptLink,
      'receiptNumber': receiptNumber,
      'balance': balance,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt?.toIso8601String(),
      'client': client?.toJson(),
      'invoice': invoice?.toJson(),
      'currency': currency?.toJson(),
      'cash': cash?.toJson(),
      'mpesa_manual': mpesaManual?.toJson(),
      'cheque': cheque?.toJson(),
      'mpesa': mpesa?.toJson(),
      'bank_transfer': bankTransfer?.toJson(),
      'bank_deposit': bankDeposit?.toJson(),
      'allocations': allocations?.map((e) => e.toJson()).toList(),
    };
  }
}
