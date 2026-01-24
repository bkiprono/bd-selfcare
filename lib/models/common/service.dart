class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String? icon;
  final String link;
  final String? image;
  final String? slug;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    required this.link,
    this.image,
    this.slug,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: json['icon']?.toString(),
      link: (json['link'] ?? '').toString(),
      image: json['image']?.toString(),
      slug: json['slug']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'link': link,
      'image': image,
      'slug': slug,
    };
  }
}
