import 'package:equatable/equatable.dart';

class QuoteItem extends Equatable {
  final String id;
  final String quoteId;
  final String name;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double discount;
  final bool discountPercentage;
  final double discountAmount;
  final double subTotal;
  final double total;
  final DateTime createdAt;

  const QuoteItem({
    required this.id,
    required this.quoteId,
    required this.name,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.discountPercentage,
    required this.discountAmount,
    required this.subTotal,
    required this.total,
    required this.createdAt,
  });

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      id: json['_id'] ?? '',
      quoteId: json['quoteId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      discountPercentage: json['discountPercentage'] ?? false,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'quoteId': quoteId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'subTotal': subTotal,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        quoteId,
        name,
        description,
        quantity,
        unitPrice,
        discount,
        discountPercentage,
        discountAmount,
        subTotal,
        total,
        createdAt,
      ];
}
