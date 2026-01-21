import 'package:bdcomputing/enums/product_enums.dart';
import 'package:bdcomputing/models/common/country.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/models/products/product_category.dart';
import 'package:bdcomputing/models/products/product_image.dart';
import 'package:bdcomputing/models/products/product_subcategory.dart';
import 'package:bdcomputing/models/common/vendor.dart';
import 'package:bdcomputing/models/products/manage_product.dart';

class Product {
  final String id; // MongoDB _id
  final String name;
  final String vendorId;
  final String slug;
  final String description;
  final String excerpt;
  final String categoryId;
  final String subCategoryId;
  final int countInStock;
  final double rating;
  final int numOfReviews;
  final bool isFeatured;
  final bool isPublished;
  final bool imagesUploaded;
  final Country countryOfOrigin;
  final String currencyId;
  final double unitPrice;
  final double sellingPrice;
  final double markupPrice;
  final double discountedPrice;
  final double discount;
  final int minStockAlert;
  final int minOrderCount;
  final int freeReturnDays;
  final int shippingDays;
  final int pickupDays;
  final int deliveryDays;
  final bool freeShipping;
  final double weight;
  final String weightUnit;
  final ProductAvailability productAvailability;
  final ProductApprovalStatus approvalStatus;
  final String? createdBy;
  final DateTime? createdAt;
  final String? productId;
  final int? v;
  final List<ProductImage> images;
  final ProductPackaging packaging;

  // Optional/nullable fields
  final Vendor? vendor;
  final ProductCategory? category;
  final ProductSubCategory? subCategory;
  final Currency? currency;

  Product({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.slug,
    required this.description,
    required this.excerpt,
    required this.categoryId,
    required this.subCategoryId,
    required this.countInStock,
    required this.rating,
    required this.numOfReviews,
    required this.isFeatured,
    required this.isPublished,
    required this.imagesUploaded,
    required this.countryOfOrigin,
    required this.currencyId,
    required this.unitPrice,
    required this.sellingPrice,
    required this.markupPrice,
    required this.discountedPrice,
    required this.discount,
    required this.minStockAlert,
    required this.minOrderCount,
    required this.productAvailability,
    required this.approvalStatus,
    this.createdBy,
    this.createdAt,
    this.productId,
    this.v,
    this.vendor,
    required this.images,
    this.category,
    this.subCategory,
    this.currency,
    required this.freeReturnDays,
    required this.shippingDays,
    required this.pickupDays,
    required this.deliveryDays,
    required this.freeShipping,
    required this.weight,
    required this.weightUnit,
    required this.packaging,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      vendorId: json['vendorId'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      excerpt: json['excerpt'] ?? '',
      categoryId: json['categoryId'] ?? '',
      subCategoryId: json['subCategoryId'] ?? '',
      countInStock: json['countInStock'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      numOfReviews: json['numOfReviews'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      isPublished: json['isPublished'] ?? false,
      imagesUploaded: json['imagesUploaded'] ?? false,
      countryOfOrigin:
          (json['countryOfOrigin'] != null &&
              json['countryOfOrigin'] is Map &&
              json['countryOfOrigin'].isNotEmpty)
          ? Country.fromJson(json['countryOfOrigin'])
          : Country(
              id: '',
              name: '',
              code: '',
              mobileCode: '',
              createdAt: null,
              createdBy: null,
            ),

      currencyId: json['currencyId'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      markupPrice: (json['markupPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      minStockAlert: json['minStockAlert'] ?? 0,
      minOrderCount: json['minOrderCount'] ?? 0,
      productAvailability: ProductAvailabilityX.fromString(
        json['productAvailability']?.toString() ?? 'global',
      ),
      approvalStatus: ProductApprovalStatusX.fromString(
        json['approvalStatus']?.toString().toUpperCase() ?? 'PENDING',
      ),
      createdBy: json['createdBy']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      productId: json['productId']?.toString(),
      v: json['__v'] is int ? json['__v'] : null,
      vendor:
          (json['vendor'] != null &&
              json['vendor'] is Map &&
              json['vendor'].isNotEmpty)
          ? Vendor.fromJson(json['vendor'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
                .map((img) => ProductImage.fromJson(img))
                .toList()
          : <ProductImage>[],
      category:
          (json['category'] != null &&
              json['category'] is Map &&
              json['category'].isNotEmpty)
          ? ProductCategory.fromJson(json['category'])
          : null,
      subCategory:
          (json['subCategory'] != null &&
              json['subCategory'] is Map &&
              json['subCategory'].isNotEmpty)
          ? ProductSubCategory.fromJson(json['subCategory'])
          : null,
      currency:
          (json['currency'] != null &&
              json['currency'] is Map &&
              json['currency'].isNotEmpty)
          ? Currency.fromJson(json['currency'])
          : null,
      freeReturnDays: json['freeReturnDays'] ?? 0,
      shippingDays: json['shippingDays'] ?? 0,
      pickupDays: json['pickupDays'] ?? 0,
      deliveryDays: json['deliveryDays'] ?? 0,
      freeShipping: json['freeShipping'] ?? false,
      weight: (json['weight'] ?? 0).toDouble(),
      weightUnit: json['weightUnit'] ?? '',
      packaging: ProductPackaging.fromJson(json['packaging'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'vendorId': vendorId,
      'slug': slug,
      'description': description,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'countInStock': countInStock,
      'rating': rating,
      'numOfReviews': numOfReviews,
      'isFeatured': isFeatured,
      'isPublished': isPublished,
      'imagesUploaded': imagesUploaded,
      'countryOfOrigin': countryOfOrigin,
      'currencyId': currencyId,
      'unitPrice': unitPrice,
      'sellingPrice': sellingPrice,
      'markupPrice': markupPrice,
      'discountedPrice': discountedPrice,
      'discount': discount,
      'minStockAlert': minStockAlert,
      'minOrderCount': minOrderCount,
      'productAvailability': productAvailability.value,
      'approvalStatus': approvalStatus.value,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'productId': productId,
      '__v': v,
      'vendor': vendor?.toJson(),
      'images': images.map((img) => img.toJson()).toList(),
      'category': category?.toJson(),
      'subCategory': subCategory?.toJson(),
      'currency': currency?.toJson(),
      'freeReturnDays': freeReturnDays,
      'shippingDays': shippingDays,
      'pickupDays': pickupDays,
      'deliveryDays': deliveryDays,
      'freeShipping': freeShipping,
      'weight': weight,
      'weightUnit': weightUnit,
      'packaging': packaging.toJson(),
    };
  }
}
