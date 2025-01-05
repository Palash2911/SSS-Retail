class OrderModel {
  String oid;
  final String uid;
  final String status;
  final String orderDateTime;
  final List<dynamic> orderItems;
  final int totalAmount;
  final int orderNo;
  final String deliveryDate;

  OrderModel({
    required this.oid,
    required this.uid,
    required this.status,
    required this.orderDateTime,
    required this.orderItems,
    required this.totalAmount,
    required this.orderNo,
    required this.deliveryDate,
  });
}
