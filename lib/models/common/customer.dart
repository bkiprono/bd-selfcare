// lib/models/customer.dart
import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double currentBalance;
  final double openingBalance;
  final bool verified;
  final String? createdBy;
  final DateTime createdAt;
  final String accountNumber;
  final String serial;
  final int uniqueId;
  final DateTime? updatedAt;
  final String? updatedBy;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.currentBalance,
    required this.openingBalance,
    required this.verified,
    this.createdBy,
    required this.createdAt,
    required this.accountNumber,
    required this.serial,
    required this.uniqueId,
    this.updatedAt,
    this.updatedBy,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      verified: json['verified'] ?? false,
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      accountNumber: json['accountNumber'] ?? '',
      serial: json['serial'] ?? '',
      uniqueId: json['uniqueId'] ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'currentBalance': currentBalance,
      'openingBalance': openingBalance,
      'verified': verified,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'accountNumber': accountNumber,
      'serial': serial,
      'uniqueId': uniqueId,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? currentBalance,
    double? openingBalance,
    bool? verified,
    String? createdBy,
    DateTime? createdAt,
    String? accountNumber,
    String? serial,
    int? uniqueId,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      currentBalance: currentBalance ?? this.currentBalance,
      openingBalance: openingBalance ?? this.openingBalance,
      verified: verified ?? this.verified,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      accountNumber: accountNumber ?? this.accountNumber,
      serial: serial ?? this.serial,
      uniqueId: uniqueId ?? this.uniqueId,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    currentBalance,
    openingBalance,
    verified,
    createdBy,
    createdAt,
    accountNumber,
    serial,
    uniqueId,
    updatedAt,
    updatedBy,
  ];
}