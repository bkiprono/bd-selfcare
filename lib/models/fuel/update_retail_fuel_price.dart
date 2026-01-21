class UpdateRetailFuelPrice {
  final String? fuelProductId;
  final String? fuelProductTypeId;
  final String? currencyId;
  final double? price;
  final double? minOrder;
  final double? maxOrder;
  final bool? supplyActive;

  UpdateRetailFuelPrice({
    this.fuelProductId,
    this.fuelProductTypeId,
    this.currencyId,
    this.price,
    this.minOrder,
    this.maxOrder,
    this.supplyActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fuelProductId != null) 'fuelProductId': fuelProductId,
      if (fuelProductTypeId != null) 'fuelProductTypeId': fuelProductTypeId,
      if (currencyId != null) 'currencyId': currencyId,
      if (price != null) 'price': price,
      if (minOrder != null) 'minOrder': minOrder,
      if (maxOrder != null) 'maxOrder': maxOrder,
      if (supplyActive != null) 'supplyActive': supplyActive,
    };
  }
}
