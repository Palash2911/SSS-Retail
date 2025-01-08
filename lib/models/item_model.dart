class ItemModel {
  final String itemId;
  final String itemName;
  final double itemPrice;
  final String itemType;
  final String parentItemId;
  final int itemOrder;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.itemType,
    required this.parentItemId,
    required this.itemOrder,
  });
}
