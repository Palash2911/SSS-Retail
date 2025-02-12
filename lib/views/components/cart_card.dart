import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sss_retail/constants/app_colors.dart';

class CartCard extends StatefulWidget {
  final Map<dynamic, dynamic> item;
  final int index;
  final void Function(int) removeItem;
  final void Function(String, int) modifyOrder;
  const CartCard({
    super.key,
    required this.item,
    required this.index,
    required this.removeItem,
    required this.modifyOrder,
  });

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 11, horizontal: 15),
          padding: EdgeInsets.symmetric(vertical: 11, horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 0.7,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          width: 295.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: SizedBox(
                  width: 176.w,
                  child: Text(
                    "${widget.index + 1}. ${widget.item['itemName']}"
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.remove,
                          color: AppColors.primary,
                          size: 25,
                        ),
                        onTap: () {
                          widget.modifyOrder(widget.item['itemId'],
                              widget.item['quantity'] - 1);
                        },
                      ),
                      Gap(2),
                      Text(
                        widget.item['quantity'].toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(2),
                      GestureDetector(
                        child: Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 25,
                        ),
                        onTap: () {
                          widget.modifyOrder(widget.item['itemId'],
                              widget.item['quantity'] + 1);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => widget.removeItem(widget.index),
          child: Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }
}
