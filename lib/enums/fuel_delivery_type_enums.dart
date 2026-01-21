enum FuelDeliveryTypeEnum {
  express('express'),
  standard('standard'),
  scheduled('scheduled');

  final String value;
  const FuelDeliveryTypeEnum(this.value);

  static FuelDeliveryTypeEnum fromString(String type) {
    return FuelDeliveryTypeEnum.values.firstWhere(
      (e) => e.value == type.toLowerCase(),
      orElse: () => FuelDeliveryTypeEnum.standard,
    );
  }
}
