import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/item_model.dart';

class AdminItemCard extends StatefulWidget {
  final ItemModel item;
  final int index;
  final bool isSelected;
  final String parentItemName;
  final void Function(String) updateItem;
  const AdminItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
    required this.parentItemName,
    required this.updateItem,
  });

  @override
  State<AdminItemCard> createState() => _AdminItemCardState();
}

class _AdminItemCardState extends State<AdminItemCard> {
  Widget _buildOrderItems(String suffix, String prefix) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 96.w,
            child: Text(
              '$prefix: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
          Flexible(
            child: Text(
              suffix,
              style: TextStyle(
                fontSize:
                    suffix == "Dry" || suffix == "Wet" || suffix == "Horeca"
                        ? 21
                        : 18,
                fontWeight: FontWeight.bold,
                color: suffix == "Dry"
                    ? Colors.green
                    : suffix == "Wet"
                        ? Colors.orange
                        : suffix == "Horeca"
                            ? Colors.blue
                            : suffix == "Delite"
                                ? Colors.indigo
                                : Colors.black,
              ),
              textAlign: TextAlign.end,
              softWrap: true,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildOrderItems(widget.item.itemId, 'Item ID'),
                _buildOrderItems(widget.item.itemName, 'Item Name'),
                if (widget.item.parentItemId.isNotEmpty) ...[
                  _buildOrderItems(widget.parentItemName, 'Parent Item'),
                ],
                _buildOrderItems(widget.item.itemType, 'Item Type'),
                _buildOrderItems("₹ ${widget.item.itemPrice}", 'Item Price'),
                Gap(6),
                ElevatedButton(
                  onPressed: () {
                    widget.updateItem(widget.item.itemId);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    backgroundColor: const Color.fromARGB(209, 230, 57, 71),
                    textStyle: const TextStyle(fontSize: 18),
                    disabledBackgroundColor: AppColors.accent,
                  ),
                  child: Text(
                    "Update Item",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
