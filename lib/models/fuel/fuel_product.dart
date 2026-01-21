import 'package:bdcomputing/models/fuel/fuel_product_type.dart';

class FuelProduct {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final List<FuelProductType>? fuelProductTypes;

  FuelProduct({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.fuelProductTypes,
  });

  factory FuelProduct.fromJson(Map<String, dynamic> json) {
    return FuelProduct(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      fuelProductTypes: json['fuelProductTypes'] != null
          ? (json['fuelProductTypes'] as List)
                .map((e) => FuelProductType.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'fuelProductTypes': fuelProductTypes?.map((e) => e.toJson()).toList(),
    };
  }
}
