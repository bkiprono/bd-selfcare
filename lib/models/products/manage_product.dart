class ProductPackaging {
  final double height;
  final double width;
  final double length;
  final String unit;

  ProductPackaging({
    required this.height,
    required this.width,
    required this.length,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'width': width,
      'length': length,
      'unit': unit,
    };
  }

  factory ProductPackaging.fromJson(Map<String, dynamic> json) {
    return ProductPackaging(
      height: (json['height'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      length: (json['length'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'cm',
    );
  }

  ProductPackaging copyWith({
    double? height,
    double? width,
    double? length,
    String? unit,
  }) {
    return ProductPackaging(
      height: height ?? this.height,
      width: width ?? this.width,
      length: length ?? this.length,
      unit: unit ?? this.unit,
    );
  }
}

class CreateProductModel {
  final bool isPublished;
  final String countryOfOriginId;
  final String vendorId;
  final String name;
  final String description;
  final String categoryId;
  final String subCategoryId;
  final int countInStock;
  final int minStockAlert;
  final int minOrderCount;
  final String productAvailability;
  final double unitPrice;
  final double sellingPrice;
  final double? discountedPrice;
  final String excerpt;
  final double weight;
  final String weightUnit;
  final ProductPackaging packaging;
  final String? currencyId;
  final int? freeReturnDays;
  final int? shippingDays;
  final int? pickupDays;
  final int? deliveryDays;
  final bool? freeShipping;
  final double? markupPrice;

  CreateProductModel({
    required this.isPublished,
    required this.countryOfOriginId,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.subCategoryId,
    required this.countInStock,
    this.minStockAlert = 0,
    this.minOrderCount = 1,
    this.productAvailability = 'global',
    required this.unitPrice,
    required this.sellingPrice,
    this.discountedPrice,
    required this.excerpt,
    required this.weight,
    this.weightUnit = 'kg',
    required this.packaging,
    this.currencyId,
    this.freeReturnDays = 0,
    this.shippingDays = 0,
    this.pickupDays = 0,
    this.deliveryDays = 0,
    this.freeShipping = false,
    this.markupPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'isPublished': isPublished,
      'countryOfOriginId': countryOfOriginId,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'countInStock': countInStock,
      'minStockAlert': minStockAlert,
      'minOrderCount': minOrderCount,
      'productAvailability': productAvailability,
      'unitPrice': unitPrice,
      'sellingPrice': sellingPrice,
      if (discountedPrice != null) 'discountedPrice': discountedPrice,
      'excerpt': excerpt,
      'weight': weight,
      'weightUnit': weightUnit,
      'packaging': packaging.toJson(),
      if (currencyId != null) 'currencyId': currencyId,
      if (freeReturnDays != null) 'freeReturnDays': freeReturnDays,
      if (shippingDays != null) 'shippingDays': shippingDays,
      if (pickupDays != null) 'pickupDays': pickupDays,
      if (deliveryDays != null) 'deliveryDays': deliveryDays,
      if (freeShipping != null) 'freeShipping': freeShipping,
      if (markupPrice != null) 'markupPrice': markupPrice,
    };
  }

  factory CreateProductModel.fromJson(Map<String, dynamic> json) {
    return CreateProductModel(
      isPublished: json['isPublished'] ?? false,
      countryOfOriginId: json['countryOfOriginId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? '',
      subCategoryId: json['subCategoryId'] ?? '',
      countInStock: json['countInStock'] ?? 0,
      minStockAlert: json['minStockAlert'] ?? 0,
      minOrderCount: json['minOrderCount'] ?? 1,
      productAvailability: json['productAvailability'] ?? 'global',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'])?.toDouble(),
      excerpt: json['excerpt'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      weightUnit: json['weightUnit'] ?? 'kg',
      packaging: ProductPackaging.fromJson(json['packaging'] ?? {}),
      currencyId: json['currencyId']?.toString(),
      freeReturnDays: json['freeReturnDays'] as int?,
      shippingDays: json['shippingDays'] as int?,
      pickupDays: json['pickupDays'] as int?,
      deliveryDays: json['deliveryDays'] as int?,
      freeShipping: json['freeShipping'] as bool?,
      markupPrice: (json['markupPrice'])?.toDouble(),
    );
  }

  CreateProductModel copyWith({
    bool? isPublished,
    String? countryOfOriginId,
    String? vendorId,
    String? name,
    String? description,
    String? categoryId,
    String? subCategoryId,
    int? countInStock,
    int? minStockAlert,
    int? minOrderCount,
    String? productAvailability,
    double? unitPrice,
    double? sellingPrice,
    double? discountedPrice,
    String? excerpt,
    double? weight,
    String? weightUnit,
    ProductPackaging? packaging,
    String? currencyId,
    int? freeReturnDays,
    int? shippingDays,
    int? pickupDays,
    int? deliveryDays,
    bool? freeShipping,
    double? markupPrice,
  }) {
    return CreateProductModel(
      isPublished: isPublished ?? this.isPublished,
      countryOfOriginId: countryOfOriginId ?? this.countryOfOriginId,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      countInStock: countInStock ?? this.countInStock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      minOrderCount: minOrderCount ?? this.minOrderCount,
      productAvailability: productAvailability ?? this.productAvailability,
      unitPrice: unitPrice ?? this.unitPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      excerpt: excerpt ?? this.excerpt,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      packaging: packaging ?? this.packaging,
      currencyId: currencyId ?? this.currencyId,
      freeReturnDays: freeReturnDays ?? this.freeReturnDays,
      shippingDays: shippingDays ?? this.shippingDays,
      pickupDays: pickupDays ?? this.pickupDays,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      freeShipping: freeShipping ?? this.freeShipping,
      markupPrice: markupPrice ?? this.markupPrice,
    );
  }

  // Validation method
  bool isValid() {
    return name.isNotEmpty &&
        description.isNotEmpty &&
        categoryId.isNotEmpty &&
        subCategoryId.isNotEmpty &&
        countryOfOriginId.isNotEmpty &&
        vendorId.isNotEmpty &&
        unitPrice > 0 &&
        sellingPrice > 0 &&
        countInStock >= 0 &&
        weight > 0;
  }

  // Calculate profit margin
  double get profitMargin {
    if (unitPrice == 0) return 0;
    return ((sellingPrice - unitPrice) / unitPrice) * 100;
  }

  // Check if product is profitable
  bool get isProfitable => sellingPrice > unitPrice;
}
