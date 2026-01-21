enum FuelOrderTypeEnum {
  bulk('bulk'),
  retail('retail');

  final String value;
  const FuelOrderTypeEnum(this.value);

  static FuelOrderTypeEnum fromString(String type) {
    return FuelOrderTypeEnum.values.firstWhere(
      (e) => e.value == type.toLowerCase(),
      orElse: () => FuelOrderTypeEnum.retail,
    );
  }
}
