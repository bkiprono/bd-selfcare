class CreateRetailFuelPrice {
  final String fuelProductId;
  final String fuelProductTypeId;
  final String currencyId;
  final double price;
  final double minOrder;
  final double maxOrder;
  final bool supplyActive;

  CreateRetailFuelPrice({
    required this.fuelProductId,
    required this.fuelProductTypeId,
    required this.currencyId,
    required this.price,
    required this.minOrder,
    required this.maxOrder,
    this.supplyActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'fuelProductId': fuelProductId,
      'fuelProductTypeId': fuelProductTypeId,
      'currencyId': currencyId,
      'price': price,
      'minOrder': minOrder,
      'maxOrder': maxOrder,
      'supplyActive': supplyActive,
    };
  }
}
