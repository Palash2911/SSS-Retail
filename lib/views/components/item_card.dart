import 'package:flutter/material.dart';
import 'package:sss_retail/constants/app_colors.dart';

class ItemCard extends StatefulWidget {
  final String itemName;
  final String itemId;
  final void Function(String) showModel;
  const ItemCard({
    super.key,
    required this.itemName,
    required this.itemId,
    required this.showModel,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 11, horizontal: 15),
      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.itemName.toString().toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => widget.showModel(widget.itemId),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.accentColor2,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    "View Items",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
