class VendorWithPrice {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String country;
  final bool verified;
  final String? taxId;
  final String? fuelPriceId;
  final double? price;
  final bool isLoadingPrice;
  final bool priceError;

  VendorWithPrice({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.country,
    required this.verified,
    this.taxId,
    this.fuelPriceId,
    this.price,
    this.isLoadingPrice = false,
    this.priceError = false,
  });

  VendorWithPrice copyWith({
    double? price,
    bool? isLoadingPrice,
    bool? priceError,
    String? fuelPriceId,
  }) {
    return VendorWithPrice(
      id: id,
      name: name,
      email: email,
      phone: phone,
      city: city,
      country: country,
      verified: verified,
      taxId: taxId,
      fuelPriceId: fuelPriceId ?? this.fuelPriceId,
      price: price ?? this.price,
      isLoadingPrice: isLoadingPrice ?? this.isLoadingPrice,
      priceError: priceError ?? this.priceError,
    );
  }
}
