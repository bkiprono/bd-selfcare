import 'package:bdcomputing/models/common/country.dart';

class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String taxId;
  final String city;
  final String countryId;
  final String currencyId;
  final String street;
  final String state;
  final String zipCode;
  final String? idNumber;
  final String? registrationNumber;
  final String contactPersonName;
  final String contactPersonPhone;
  final String contactPersonEmail;
  final String serial;
  final int? uniqueId;
  final bool verified;
  final bool isActive;
  final Country? country;
  final double currentBalance;
  final double openingBalance;
  final bool isProductVendor;
  final bool isProductVendorApproved;
  final bool isFuelVendor;
  final bool isFuelVendorApproved;
  final bool fuelBulk;
  final bool fuelRetail;
  // final List<VendorDocument> documents;
  // final List<FuelPrice> fuelPrices;
  final bool hasAllProductFiles;
  final bool allProductFilesApproved;
  final bool hasAllFuelFiles;
  final bool allFuelFilesApproved;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.taxId,
    required this.city,
    required this.countryId,
    required this.currencyId,
    required this.street,
    required this.state,
    required this.zipCode,
    this.idNumber,
    this.registrationNumber,
    required this.contactPersonName,
    required this.contactPersonPhone,
    required this.contactPersonEmail,
    required this.serial,
    this.uniqueId,
    required this.verified,
    required this.isActive,
    this.country,
    required this.currentBalance,
    required this.openingBalance,
    required this.isProductVendor,
    required this.isProductVendorApproved,
    required this.isFuelVendor,
    required this.isFuelVendorApproved,
    required this.fuelBulk,
    required this.fuelRetail,
    // required this.documents,
    // required this.fuelPrices,
    required this.hasAllProductFiles,
    required this.allProductFilesApproved,
    required this.hasAllFuelFiles,
    required this.allFuelFilesApproved,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      taxId: json['taxId'] ?? '',
      city: json['city'] ?? '',
      countryId: json['countryId'] ?? '',
      currencyId: json['currencyId'] ?? '',
      street: json['street'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      idNumber: json['idNumber'],
      registrationNumber: json['registrationNumber'],
      contactPersonName: json['contactPersonName'] ?? '',
      contactPersonPhone: json['contactPersonPhone'] ?? '',
      contactPersonEmail: json['contactPersonEmail'] ?? '',
      serial: json['serial'] ?? '',
      uniqueId: json['uniqueId'],
      verified: json['verified'] ?? false,
      isActive: json['isActive'] ?? false,
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      isProductVendor: json['isProductVendor'] ?? false,
      isProductVendorApproved: json['isProductVendorApproved'] ?? false,
      isFuelVendor: json['isFuelVendor'] ?? false,
      isFuelVendorApproved: json['isFuelVendorApproved'] ?? false,
      fuelBulk: json['fuel']?['bulk'] ?? false,
      fuelRetail: json['fuel']?['retail'] ?? false,
      // documents: json['documents'] != null
      //     ? (json['documents'] as List)
      //         .map((doc) => VendorDocument.fromJson(doc))
      //         .toList()
      //     : [],
      // fuelPrices: json['fuelPrices'] != null
      //     ? (json['fuelPrices'] as List)
      //         .map((opt) => FuelPrice.fromJson(opt))
      //         .toList()
      //     : [],
      hasAllProductFiles: json['hasAllProductFiles'] ?? false,
      allProductFilesApproved: json['allProductFilesApproved'] ?? false,
      hasAllFuelFiles: json['hasAllFuelFiles'] ?? false,
      allFuelFilesApproved: json['allFuelFilesApproved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'taxId': taxId,
      'city': city,
      'countryId': countryId,
      'currencyId': currencyId,
      'street': street,
      'state': state,
      'zipCode': zipCode,
      'idNumber': idNumber,
      'registrationNumber': registrationNumber,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'contactPersonEmail': contactPersonEmail,
      'serial': serial,
      'uniqueId': uniqueId,
      'verified': verified,
      'isActive': isActive,
      'country': country?.toJson(),
      'currentBalance': currentBalance,
      'openingBalance': openingBalance,
      'isProductVendor': isProductVendor,
      'isProductVendorApproved': isProductVendorApproved,
      'isFuelVendor': isFuelVendor,
      'isFuelVendorApproved': isFuelVendorApproved,
      'fuel': {'bulk': fuelBulk, 'retail': fuelRetail},
      // "documents": documents.map((d) => d.toJson() ).toList(),
      // "fuelPrices": fuelPrices.map((f) => f.toJson()).toList(),
      'hasAllProductFiles': hasAllProductFiles,
      'allProductFilesApproved': allProductFilesApproved,
      'hasAllFuelFiles': hasAllFuelFiles,
      'allFuelFilesApproved': allFuelFilesApproved,
    };
  }
}

class VendorRegister {
  final String name;
  final String email;
  final String phone;
  final String city;
  final String countryId;
  final String street;
  final String state;
  final String zipCode;
  final String contactPersonName;
  final String contactPersonPhone;
  final String contactPersonEmail;
  final String password;
  final String currencyId;
  final bool fuelVendor;
  final bool productVendor;

  VendorRegister({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.countryId,
    required this.street,
    required this.state,
    required this.zipCode,
    required this.contactPersonName,
    required this.contactPersonPhone,
    required this.contactPersonEmail,
    required this.password,
    required this.currencyId,
    required this.fuelVendor,
    required this.productVendor,
  });

  factory VendorRegister.fromJson(Map<String, dynamic> json) {
    return VendorRegister(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      countryId: json['countryId'] ?? '',
      street: json['street'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      contactPersonName: json['contactPersonName'] ?? '',
      contactPersonPhone: json['contactPersonPhone'] ?? '',
      contactPersonEmail: json['contactPersonEmail'] ?? '',
      password: json['password'] ?? '',
      currencyId: json['currencyId'] ?? '',
      fuelVendor: json['fuelVendor'] ?? false,
      productVendor: json['productVendor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'countryId': countryId,
      'street': street,
      'state': state,
      'zipCode': zipCode,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'contactPersonEmail': contactPersonEmail,
      'password': password,
      'currencyId': currencyId,
      'fuelVendor': fuelVendor,
      'productVendor': productVendor,
    };
  }
}
