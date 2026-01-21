import 'package:bdcomputing/enums/fuel_order_type_enums.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/models/common/vendor.dart';
import 'package:bdcomputing/models/fuel/fuel_product.dart';
import 'package:bdcomputing/models/fuel/fuel_product_type.dart';

class FuelPrice {
  final String id;
  final String? fuelProductTypeId;
  final String fuelProductId;
  final FuelOrderTypeEnum type;
  final double price;
  final String currencyId;
  final double minOrder;
  final double maxOrder;
  final String vendorId;
  final bool supplyActive;
  final bool isActive;

  // Expanded relations (optional depending on API population)
  final FuelProduct? fuelProduct;
  final FuelProductType? fuelProductType;
  final Currency? currency;
  final Vendor? vendor;

  FuelPrice({
    required this.id,
    required this.fuelProductTypeId,
    required this.fuelProductId,
    required this.type,
    required this.price,
    required this.currencyId,
    required this.minOrder,
    required this.maxOrder,
    required this.vendorId,
    required this.supplyActive,
    required this.isActive,
    this.fuelProduct,
    this.fuelProductType,
    this.currency,
    this.vendor,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      id: json['_id']?.toString() ?? '',
      fuelProductTypeId: json['fuelProductTypeId']?.toString(),
      fuelProductId: json['fuelProductId']?.toString() ?? '',
      type: FuelOrderTypeEnum.fromString(json['type']?.toString() ?? 'retail'),
      price: (json['price'] ?? 0).toDouble(),
      currencyId: json['currencyId']?.toString() ?? '',
      minOrder: (json['minOrder'] ?? 0).toDouble(),
      maxOrder: (json['maxOrder'] ?? 0).toDouble(),
      vendorId: json['vendorId']?.toString() ?? '',
      supplyActive: json['supplyActive'] ?? false,
      isActive: json['isActive'] ?? false,
      fuelProduct: json['fuelProduct'] != null
          ? FuelProduct.fromJson(json['fuelProduct'] as Map<String, dynamic>)
          : null,
      fuelProductType: json['fuelProductType'] != null
          ? FuelProductType.fromJson(
              json['fuelProductType'] as Map<String, dynamic>,
            )
          : null,
      currency: json['currency'] != null
          ? Currency.fromJson(json['currency'] as Map<String, dynamic>)
          : null,
      vendor: json['vendor'] != null
          ? Vendor.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fuelProductTypeId': fuelProductTypeId,
      'fuelProductId': fuelProductId,
      'type': type.value,
      'price': price,
      'currencyId': currencyId,
      'minOrder': minOrder,
      'maxOrder': maxOrder,
      'vendorId': vendorId,
      'supplyActive': supplyActive,
      'isActive': isActive,
      if (fuelProduct != null) 'fuelProduct': fuelProduct!.toJson(),
      if (fuelProductType != null) 'fuelProductType': fuelProductType!.toJson(),
      if (currency != null) 'currency': currency!.toJson(),
      if (vendor != null) 'vendor': vendor!.toJson(),
    };
  }
}
