class Product {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String slug;

  Product({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    required this.slug,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      logo: json['logo']?.toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'slug': slug,
    };
  }
}
