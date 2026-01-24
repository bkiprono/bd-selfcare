import 'package:bdoneapp/models/common/country.dart';

class Address {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String postalCode;
  final String boxAddress;
  final String town;
  final String countryId;
  final String userId;
  final String createdBy;
  final String? label; // Home, Office, Custom
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;
  final Country? country;

  Address({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.boxAddress,
    required this.town,
    required this.countryId,
    required this.userId,
    required this.createdBy,
    this.label,
    this.landmark,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      street: (json['street'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      postalCode: (json['postalCode'] ?? '') as String,
      boxAddress: (json['boxAddress'] ?? '') as String,
      town: (json['town'] ?? '') as String,
      countryId: (json['countryId'] ?? '') as String,
      userId: (json['userId'] ?? '') as String,
      createdBy: (json['createdBy'] ?? '') as String,
      label: json['label'] as String?,
      landmark: json['landmark'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      updatedBy: json['updatedBy'] as String?,
      country: json['country'] != null
          ? Country.fromJson(json['country'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'boxAddress': boxAddress,
      'town': town,
      'countryId': countryId,
      if (userId.isNotEmpty) 'userId': userId,
      if (createdBy.isNotEmpty) 'createdBy': createdBy,
      if (label != null) 'label': label,
      if (landmark != null && landmark!.isNotEmpty) 'landmark': landmark,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (updatedBy != null) 'updatedBy': updatedBy,
      if (country != null) 'country': country!.toJson(),
    };
  }

  factory Address.empty() {
    return Address(
      id: '',
      name: '',
      email: '',
      phone: '',
      street: '',
      city: '',
      postalCode: '',
      boxAddress: '',
      town: '',
      countryId: '',
      userId: '',
      createdBy: '',
    );
  }

  Address copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? street,
    String? city,
    String? postalCode,
    String? boxAddress,
    String? town,
    String? countryId,
    String? userId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
    Country? country,
    String? label,
    String? landmark,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      boxAddress: boxAddress ?? this.boxAddress,
      town: town ?? this.town,
      countryId: countryId ?? this.countryId,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      country: country ?? this.country,
      label: label ?? this.label,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // ONLY ADDITION: Helper getter to get the effective country ID for socket emissions
  String? get effectiveCountryId {
    if (country != null && country!.id.isNotEmpty) {
      return country!.id;
    }
    if (countryId.isNotEmpty) {
      return countryId;
    }
    return null;
  }
}
