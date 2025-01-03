class UserModel {
  final String uid;
  String name;
  String phone;
  String dealerShipName;
  final String lastOrderId;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.dealerShipName,
    required this.lastOrderId,
    required this.isAdmin,
  });
}
