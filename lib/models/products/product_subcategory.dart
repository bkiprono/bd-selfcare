import 'package:bdcomputing/models/common/uploaded_file.dart';

class ProductSubCategory {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String createdBy;
  final DateTime? createdAt;
  final String? fileId;
  final FileModel? image;

  final DateTime? updatedAt;
  final String updatedBy;

  ProductSubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    this.fileId,
    this.image,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory ProductSubCategory.fromJson(Map<String, dynamic> json) {
    return ProductSubCategory(
      id: json['_id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
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
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      updatedBy: json['updatedBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'fileId': fileId,
      'image': image,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}
