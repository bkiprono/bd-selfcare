class Term {
  final String id;
  final String termsCategory;
  final String title;
  final List<String> content;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final String? deletedBy;
  final DateTime? deletedAt;

  Term({
    required this.id,
    required this.termsCategory,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.deletedBy,
    this.deletedAt,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['_id'] as String,
      termsCategory: json['termsCategory'] as String,
      title: json['title'] as String,
      content: List<String>.from(json['content'] as List),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedBy: json['updatedBy'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deletedBy: json['deletedBy'] as String?,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'termsCategory': termsCategory,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedBy': deletedBy,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
