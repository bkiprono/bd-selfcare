import 'package:bdcomputing/models/products/product_subcategory.dart';
import 'package:bdcomputing/models/common/uploaded_file.dart';

class ProductCategory {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime? createdAt;
  final String? fileId;
  final FileModel? image;
  final DateTime? updatedAt;
  final List<ProductSubCategory> subCategories;
  final String updatedBy;

  ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.fileId,
    required this.updatedAt,
    required this.subCategories,
    this.image,
    required this.updatedBy,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      fileId: json['fileId']?.toString() ?? '',
      image:
          (json['image'] != null &&
              json['image'] is Map &&
              json['image'].isNotEmpty)
          ? FileModel.fromJson(json['image'])
          : null,
      subCategories:
          (json['subCategories'] != null && json['subCategories'] is List)
          ? (json['subCategories'] as List)
                .map((e) => ProductSubCategory.fromJson(e))
                .toList()
          : <ProductSubCategory>[],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      updatedBy: json['updatedBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'subCategories': subCategories,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'fileId': fileId,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}
