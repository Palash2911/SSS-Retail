class OrderModel {
  String oid;
  final String uid;
  final String status;
  final String orderDateTime;
  final List<dynamic> orderItems;
  final int totalAmount;

  OrderModel({
    required this.oid,
    required this.uid,
    required this.status,
    required this.orderDateTime,
    required this.orderItems,
    required this.totalAmount,
  });
}
