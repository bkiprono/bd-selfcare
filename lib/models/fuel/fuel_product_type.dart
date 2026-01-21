import 'package:bdcomputing/models/fuel/fuel_product.dart';

class FuelProductType {
  final String id;
  final String name;
  final String? fuelProductId;
  final String? description;
  final bool isActive;
  final FuelProduct? fuelProduct;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  FuelProductType({
    required this.id,
    required this.name,
    this.fuelProductId,
    this.description,
    required this.isActive,
    this.fuelProduct,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy, required int price,
  });

  factory FuelProductType.fromJson(Map<String, dynamic> json) {
    return FuelProductType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      fuelProductId: json['fuelProductId'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      fuelProduct: json['fuelProduct'] != null
          ? FuelProduct.fromJson(json['fuelProduct'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'], price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'fuelProductId': fuelProductId,
      'description': description,
      'isActive': isActive,
      'fuelProduct': fuelProduct?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}
