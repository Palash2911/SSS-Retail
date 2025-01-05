import 'package:flutter/material.dart';
import 'package:sss_retail/models/item_model.dart';

class AdminItemCard extends StatefulWidget {
  final ItemModel item;
  final int index;
  final bool isSelected;
  const AdminItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
  });

  @override
  State<AdminItemCard> createState() => _AdminItemCardState();
}

class _AdminItemCardState extends State<AdminItemCard> {
  Widget _buildOrderItems(String suffix, String prefix) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$prefix: ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            suffix,
            style: TextStyle(
              fontSize: suffix == "Dry" || suffix == "Wet" ? 21 : 18,
              fontWeight: FontWeight.bold,
              color: suffix == "Dry"
                  ? Colors.green
                  : suffix == "Wet"
                      ? Colors.orange
                      : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: widget.isSelected ? Colors.black : Colors.white,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItems(widget.item.itemName, 'Item'),
                _buildOrderItems(widget.item.itemId, 'Item ID'),
                _buildOrderItems(widget.item.itemType, 'Item Type'),
                _buildOrderItems("₹ ${widget.item.itemPrice}", 'Item Price'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
