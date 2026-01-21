class Country {
  final String id;
  final String name;
  final String code;
  final String mobileCode;
  final DateTime? createdAt;
  final String? createdBy;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.mobileCode,
    this.createdAt,
    this.createdBy,
    this.commissionRates,
  });

  factory Country.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Country(
        id: '',
        name: '',
        code: '',
        mobileCode: '',
        createdAt: null,
        createdBy: null,
      );
    }
    return Country(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      mobileCode: json['mobileCode'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      createdBy: json['createdBy'],
      commissionRates: json['commissionRates'] != null
          ? CommissionRates.fromJson(json['commissionRates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'mobileCode': mobileCode,
      'createdAt': createdAt?.toIso8601String(),
      'createdBy': createdBy,
      'commissionRates': commissionRates?.toJson(),
    };
  }

  factory Country.empty() {
    return Country(
      id: '',
      name: '',
      code: '',
      mobileCode: '',
      createdAt: null,
      createdBy: null,
      commissionRates: null,
    );
  }

  Country copyWith({
    String? id,
    String? name,
    String? code,
    String? mobileCode,
    DateTime? createdAt,
    String? createdBy,
    CommissionRates? commissionRates,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      mobileCode: mobileCode ?? this.mobileCode,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      commissionRates: commissionRates ?? this.commissionRates,
    );
  }

  bool get isEmpty => id.isEmpty && name.isEmpty;
  bool get isNotEmpty => !isEmpty;

  final CommissionRates? commissionRates;
}

class CommissionRates {
  final CommissionDetails? product;

  CommissionRates({this.product});

  factory CommissionRates.fromJson(Map<String, dynamic> json) {
    return CommissionRates(
      product: json['product'] != null
          ? CommissionDetails.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product?.toJson(),
    };
  }
}

class CommissionDetails {
  final num rate;
  final bool isPercentage;

  CommissionDetails({
    required this.rate,
    required this.isPercentage,
  });

  factory CommissionDetails.fromJson(Map<String, dynamic> json) {
    return CommissionDetails(
      rate: json['rate'] ?? 0,
      isPercentage: json['isPercentage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'isPercentage': isPercentage,
    };
  }
}
