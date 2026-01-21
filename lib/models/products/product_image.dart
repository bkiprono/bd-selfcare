class ProductImage {
  final String id;
  final String productId;
  final String link;
  final String description;
  final String fileId;
  final String createdBy;
  final DateTime? createdAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.link,
    required this.description,
    required this.fileId,
    required this.createdBy,
    this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      fileId: json['fileId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'link': link,
      'description': description,
      'fileId': fileId,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}