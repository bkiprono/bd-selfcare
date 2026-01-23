import 'package:bdcomputing/models/common/invoice.dart';

class PaymentAllocationItem {
  final String? id;
  final String allocationId;
  final String paymentId;
  final String currencyId;
  final String invoiceId;
  final double amount;
  final DateTime allocationDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Relations
  final Invoice? invoice;

  PaymentAllocationItem({
    this.id,
    required this.allocationId,
    required this.paymentId,
    required this.currencyId,
    required this.invoiceId,
    required this.amount,
    required this.allocationDate,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.invoice,
  });

  factory PaymentAllocationItem.fromJson(Map<String, dynamic> json) {
    return PaymentAllocationItem(
      id: (json['_id'] ?? json['id'])?.toString(),
      allocationId: (json['allocationId'] ?? '').toString(),
      paymentId: (json['paymentId'] ?? '').toString(),
      currencyId: (json['currencyId'] ?? '').toString(),
      invoiceId: (json['invoiceId'] ?? '').toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      allocationDate: json['allocationDate'] != null
          ? DateTime.parse(json['allocationDate'])
          : DateTime.now(),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      invoice: json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'allocationId': allocationId,
      'paymentId': paymentId,
      'currencyId': currencyId,
      'invoiceId': invoiceId,
      'amount': amount,
      'allocationDate': allocationDate.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'invoice': invoice?.toJson(),
    };
  }
}
