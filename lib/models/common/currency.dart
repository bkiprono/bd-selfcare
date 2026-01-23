class Currency {
  final String id;
  final String currencyId;
  final String name;
  final String code;
  final String icon;
  final bool isIconImage;
  final bool isBaseCurrency;
  final bool isCurrencySupported;
  final String? createdBy;
  final DateTime? createdAt;
  final double rateAgainstBaseCurrency;

  Currency({
    required this.id,
    required this.currencyId,
    required this.name,
    required this.code,
    required this.icon,
    required this.isIconImage,
    required this.isBaseCurrency,
    required this.isCurrencySupported,
    required this.createdBy,
    required this.createdAt,
    required this.rateAgainstBaseCurrency,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      currencyId: (json['currencyId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      isIconImage: json['isIconImage'] ?? false,
      isBaseCurrency: json['isBaseCurrency'] ?? false,
      isCurrencySupported: json['isCurrencySupported'] ?? false,
      createdBy: json['createdBy']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      rateAgainstBaseCurrency: (json['rateAgainstBaseCurrency'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'currencyId': currencyId,
      'name': name,
      'code': code,
      'icon': icon,
      'isIconImage': isIconImage,
      'isBaseCurrency': isBaseCurrency,
      'isCurrencySupported': isCurrencySupported,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'rateAgainstBaseCurrency': rateAgainstBaseCurrency,
    };
  }
}