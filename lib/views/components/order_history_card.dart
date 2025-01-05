import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/constants/utils.dart';
import 'package:sss_retail/models/order_model.dart';

class OrderHistoryCard extends StatefulWidget {
  final OrderModel order;
  final void Function(int, List<dynamic>) showOrderDetailsDialog;
  final int index;
  final bool isSelected;
  final void Function(String id) cancelOrder;
  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.showOrderDetailsDialog,
    required this.index,
    required this.isSelected,
    required this.cancelOrder,
  });

  @override
  State<OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<OrderHistoryCard> {
  Widget _buildOrderItems(String suffix, String prefix) {
    return InkWell(
      onTap: () {
        widget.showOrderDetailsDialog(widget.index, widget.order.orderItems);
      },
      child: Padding(
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: suffix == "Pending"
                    ? Colors.orange
                    : suffix == "Completed"
                        ? Colors.green
                        : suffix == "Cancelled"
                            ? Colors.red
                            : Colors.black,
              ),
            ),
          ],
        ),
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
                _buildOrderItems("#${widget.order.orderNo}", "Order ID"),
                _buildOrderItems(widget.order.status, "Status"),
                _buildOrderItems(
                    formatUnixDate(widget.order.orderDateTime), "Order Date"),
                if (widget.order.status == "Pending") ...[
                  _buildOrderItems(
                      formatUnixTime(widget.order.orderDateTime), "Order Time"),
                ],
                if (widget.order.status != "Cancelled") ...[
                  _buildOrderItems(formatUnixDate(widget.order.deliveryDate),
                      "Delivery Date"),
                ],
                _buildOrderItems(
                    '₹ ${widget.order.totalAmount}', "Total Amount"),
                if (widget.order.status == "Pending") ...[
                  Gap(11),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.cancelOrder(widget.order.oid);
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        backgroundColor: const Color.fromARGB(209, 230, 57, 71),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.w),
                        textStyle: const TextStyle(fontSize: 18),
                        disabledBackgroundColor: AppColors.accent,
                      ),
                      child: Text(
                        "Delete Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
