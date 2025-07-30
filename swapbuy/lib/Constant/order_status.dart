enum OrderStatus {
  pending('Pending'),
  accepted('Accepted'),
  preparing('Preparing'),
  outForDelivery('Out for Delivery'),
  delivered('Delivered');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  static List<String> get allValues =>
      OrderStatus.values.map((e) => e.value).toList();
}
