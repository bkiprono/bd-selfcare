import 'package:bdcomputing/models/common/address.dart';
import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/enums/fuel_order_type_enums.dart';
import 'package:bdcomputing/enums/fuel_delivery_type_enums.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/models/common/customer.dart';
import 'package:bdcomputing/models/common/vendor.dart';

class FuelOrderItem {
  final String fuelPriceId;
  final double price;
  final int quantity;
  final String currencyId;
  final String description;

  FuelOrderItem({
    required this.fuelPriceId,
    required this.price,
    required this.quantity,
    required this.currencyId,
    required this.description,
  });

  factory FuelOrderItem.fromJson(Map<String, dynamic> json) {
    return FuelOrderItem(
      fuelPriceId: json['fuelPriceId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      currencyId: json['currencyId'] ?? '',
      description: json['description'] ?? '',
    );
  }

  double get total => price * quantity;
}

class FuelOrder {
  final String id;
  final String serial;
  final FuelOrderTypeEnum orderType;
  final FuelDeliveryTypeEnum deliveryType;
  final OrderStatusEnum status;
  final double subTotal;
  final double discount;
  final double vat;
  final double total;
  final Currency currency;
  final List<FuelOrderItem> items;
  final Customer customer;
  final Vendor vendor;
  final Address? shippingAddress;
  final Address? billingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool confirmed;
  final bool delivered;

  FuelOrder({
    required this.id,
    required this.serial,
    required this.orderType,
    required this.deliveryType,
    required this.status,
    required this.subTotal,
    required this.discount,
    required this.vat,
    required this.total,
    required this.currency,
    required this.items,
    required this.customer,
    required this.vendor,
    this.shippingAddress,
    this.billingAddress,
    required this.createdAt,
    required this.updatedAt,
    required this.confirmed,
    required this.delivered,
  });

  factory FuelOrder.fromJson(Map<String, dynamic> json) {
    return FuelOrder(
      id: json['_id'] ?? json['id'] ?? '',
      serial: json['serial'] ?? '',
      orderType: FuelOrderTypeEnum.fromString(json['orderType'] ?? 'retail'),
      deliveryType: FuelDeliveryTypeEnum.fromString(
        json['deliveryType'] ?? 'standard',
      ),
      status: OrderStatusEnum.fromString(json['status'] ?? 'pending'),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      vat: (json['VAT'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      currency: Currency.fromJson(json['currency'] ?? {}),
      items:
          (json['fuelOrderItems'] as List<dynamic>?)
              ?.map((item) => FuelOrderItem.fromJson(item))
              .toList() ??
          [],
      customer: Customer.fromJson(json['customer'] ?? {}),
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      shippingAddress: json['shippingAddress'] != null
          ? Address.fromJson(json['shippingAddress'])
          : null,
      billingAddress: json['billingAddress'] != null
          ? Address.fromJson(json['billingAddress'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      confirmed: json['confirmed'] ?? false,
      delivered: json['delivered'] ?? false,
    );
  }
}

class FuelOrdersResponse {
  final List<FuelOrder> data;
  final int page;
  final int pages;
  final int total;

  FuelOrdersResponse({
    required this.data,
    required this.page,
    required this.pages,
    required this.total,
  });

  factory FuelOrdersResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>?;

    return FuelOrdersResponse(
      data:
          (dataMap?['data'] as List<dynamic>?)
              ?.map((order) => FuelOrder.fromJson(order))
              .toList() ??
          [],
      page: dataMap?['page'] ?? 1,
      pages: dataMap?['pages'] ?? 1,
      total: dataMap?['total'] ?? 0,
    );
  }
}
