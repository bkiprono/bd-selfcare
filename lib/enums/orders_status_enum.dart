enum OrderStatusEnum {
  completed('completed'),
  pending('pending'),
  cancelled('cancelled');

  final String value;
  const OrderStatusEnum(this.value);

  static OrderStatusEnum fromString(String status) {
    return OrderStatusEnum.values.firstWhere(
      (e) => e.value == status.toLowerCase(),
      orElse: () => OrderStatusEnum.pending,
    );
  }
}
