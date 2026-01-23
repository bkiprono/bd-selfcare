import 'package:bdcomputing/models/payments/payment_allocation_item.dart';

class PaymentAllocation {
  final String? id;
  final String paymentId;
  final String currencyId;
  final String? invoiceId;
  final String serial;
  final double amount;
  final DateTime allocationDate;
  final String? notes;
  final List<PaymentAllocationItem> allocations;
  final String? allocationLink;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  PaymentAllocation({
    this.id,
    required this.paymentId,
    required this.currencyId,
    this.invoiceId,
    required this.serial,
    required this.amount,
    required this.allocationDate,
    this.notes,
    required this.allocations,
    this.allocationLink,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) {
    return PaymentAllocation(
      id: (json['_id'] ?? json['id'])?.toString(),
      paymentId: (json['paymentId'] ?? '').toString(),
      currencyId: (json['currencyId'] ?? '').toString(),
      invoiceId: json['invoiceId']?.toString(),
      serial: (json['serial'] ?? '').toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      allocationDate: json['allocationDate'] != null
          ? DateTime.parse(json['allocationDate'])
          : DateTime.now(),
      notes: json['notes']?.toString(),
      allocations: (json['allocations'] as List? ?? [])
          .map((e) => PaymentAllocationItem.fromJson(e))
          .toList(),
      allocationLink: json['allocationLink']?.toString(),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentId': paymentId,
      'currencyId': currencyId,
      'invoiceId': invoiceId,
      'serial': serial,
      'amount': amount,
      'allocationDate': allocationDate.toIso8601String(),
      'notes': notes,
      'allocations': allocations.map((e) => e.toJson()).toList(),
      'allocationLink': allocationLink,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
}
