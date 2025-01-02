class ItemModel {
  final String itemId;
  final String itemName;
  final int itemPrice;
  final String itemType;
  final String parentItemId;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.itemType,
    required this.parentItemId,
  });
}
