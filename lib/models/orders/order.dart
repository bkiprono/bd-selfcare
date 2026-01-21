import 'package:bdcomputing/models/common/address.dart';
import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/models/common/customer.dart';
import 'package:bdcomputing/models/common/invoice.dart';
import 'package:bdcomputing/models/orders/order_item.dart';

class Order {
  final String id;
  final String customerId;
  final String serial;
  final String currencyId;
  final OrderStatusEnum status;
  final double subTotal;
  final String? discountCode;
  final double discount;
  final double vatRate;
  final double vat;
  final double total;
  final String billingAddressId;
  final String shippingAddressId;
  final bool confirmed;
  final bool delivered;
  final String createdBy;
  final DateTime createdAt;
  final List<OrderItem> items;
  final Invoice invoice;
  final Address shippingAddress;
  final Address billingAddress;
  final Customer customer;
  final Currency currency;

  Order({
    required this.id,
    required this.customerId,
    required this.serial,
    required this.currencyId,
    required this.status,
    required this.subTotal,
    this.discountCode,
    required this.discount,
    required this.vatRate,
    required this.vat,
    required this.total,
    required this.billingAddressId,
    required this.shippingAddressId,
    required this.confirmed,
    required this.delivered,
    required this.createdBy,
    required this.createdAt,
    required this.items,
    required this.invoice,
    required this.shippingAddress,
    required this.billingAddress,
    required this.customer,
    required this.currency,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: json['customerId'],
      serial: json['serial'] ?? '',
      currencyId: json['currencyId'],
      status: OrderStatusEnum.fromString(json['status'] ?? 'pending'),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      discountCode: json['discountCode'],
      discount: (json['discount'] ?? 0).toDouble(),
      vatRate: (json['VATRate'] ?? 0).toDouble(),
      vat: (json['VAT'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      billingAddressId: json['billingAddressId'],
      shippingAddressId: json['shippingAddressId'],
      confirmed: json['confirmed'] ?? false,
      delivered: json['delivered'] ?? false,
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      invoice: Invoice.fromJson(json['invoice']),
      shippingAddress: Address.fromJson(json['shippingAddress']),
      billingAddress: Address.fromJson(json['billingAddress']),
      customer: Customer.fromJson(json['customer']),
      currency: Currency.fromJson(json['currency']),
    );
  }
}

class OrdersResponse {
  final List<Order> data;
  final int page;
  final int pages;
  final int total;

  OrdersResponse({
    required this.data,
    required this.page,
    required this.pages,
    required this.total,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((order) => Order.fromJson(order))
              .toList() ??
          [],
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
