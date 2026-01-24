import 'package:bdoneapp/models/enums/industry_enum.dart';

class ClientRegistration {
  final String name;
  final String email;
  final String phone;
  final String? kraPIN;
  final String? idNumber;
  final String? incorporationNumber;
  final Industry industry;
  final String countryId;
  final String city;
  final String state;
  final String street;
  final String zipCode;
  final bool isCorporate;
  final String password;

  const ClientRegistration({
    required this.name,
    required this.email,
    required this.phone,
    this.kraPIN,
    this.idNumber,
    this.incorporationNumber,
    required this.industry,
    required this.countryId,
    required this.city,
    required this.state,
    required this.street,
    required this.zipCode,
    required this.isCorporate,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'KRA_PIN': kraPIN?.trim().isEmpty == true ? null : kraPIN?.trim(),
      'idNumber': idNumber?.trim().isEmpty == true ? null : idNumber?.trim(),
      'incorporationNumber': incorporationNumber?.trim().isEmpty == true 
          ? null 
          : incorporationNumber?.trim(),
      'industry': industry.value,
      'countryId': countryId,
      'city': city,
      'state': state,
      'street': street,
      'zipCode': zipCode,
      'isCorporate': isCorporate,
      'password': password,
      'source': 'MOBILE_APP', // Lead source
    };
  }

  factory ClientRegistration.fromJson(Map<String, dynamic> json) {
    return ClientRegistration(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      kraPIN: json['KRA_PIN'],
      idNumber: json['idNumber'],
      incorporationNumber: json['incorporationNumber'],
      industry: IndustryExtension.fromString(json['industry'] ?? 'OTHER'),
      countryId: json['countryId'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      street: json['street'] ?? '',
      zipCode: json['zipCode'] ?? '',
      isCorporate: json['isCorporate'] ?? false,
      password: json['password'] ?? '',
    );
  }
}
