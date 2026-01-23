class CustomerMessageCreate {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? purpose;
  final String? message;
  final String source;

  CustomerMessageCreate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.purpose,
    this.message,
    this.source = 'bd-otg',
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      if (purpose != null && purpose!.isNotEmpty) 'purpose': purpose,
      if (message != null && message!.isNotEmpty) 'message': message,
      'source': source,
    };
  }
}

class CustomerMessage {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? purpose;
  final String? message;
  final String source;
  final DateTime? createdAt;

  CustomerMessage({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.purpose,
    this.message,
    required this.source,
    this.createdAt,
  });

  factory CustomerMessage.fromJson(Map<String, dynamic> json) {
    return CustomerMessage(
      id: (json['id'] ?? '').toString(),
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      purpose: json['purpose'],
      message: json['message'],
      source: json['source'] ?? 'bd-otg',
      // createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? ''),
       createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}


