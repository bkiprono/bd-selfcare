import 'package:equatable/equatable.dart';
import 'package:bdcomputing/models/products/product.dart';

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String vendorId;
  final double price;
  final int quantity;
  final double subTotal;
  final String? discountCode;
  final double discount;
  final double vatRate;
  final double vat;
  final double total;
  final String createdBy;
  final DateTime createdAt;
  final Product product;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.vendorId,
    required this.price,
    required this.quantity,
    required this.subTotal,
    this.discountCode,
    required this.discount,
    required this.vatRate,
    required this.vat,
    required this.total,
    required this.createdBy,
    required this.createdAt,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      productId: json['productId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      discountCode: json['discountCode'],
      discount: (json['discount'] ?? 0).toDouble(),
      vatRate: (json['VATRate'] ?? 0).toDouble(),
      vat: (json['VAT'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      product: Product.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'productId': productId,
      'vendorId': vendorId,
      'price': price,
      'quantity': quantity,
      'subTotal': subTotal,
      'discountCode': discountCode,
      'discount': discount,
      'VATRate': vatRate,
      'VAT': vat,
      'total': total,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'product': product,
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? vendorId,
    double? price,
    int? quantity,
    double? subTotal,
    String? discountCode,
    double? discount,
    double? vatRate,
    double? vat,
    double? total,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      vendorId: vendorId ?? this.vendorId,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subTotal: subTotal ?? this.subTotal,
      discountCode: discountCode ?? this.discountCode,
      discount: discount ?? this.discount,
      vatRate: vatRate ?? this.vatRate,
      vat: vat ?? this.vat,
      total: total ?? this.total,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      product: product,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        vendorId,
        price,
        quantity,
        subTotal,
        discountCode,
        discount,
        vatRate,
        vat,
        total,
        createdBy,
        createdAt,
        product
      ];
}