class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String dealerShipName;
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
