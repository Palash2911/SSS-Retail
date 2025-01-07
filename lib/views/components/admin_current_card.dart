import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/utils.dart';
import 'package:sss_retail/models/order_model.dart';
import 'package:sss_retail/providers/user_provider.dart';

class AdminCurrentCard extends StatefulWidget {
  final OrderModel order;
  final void Function(int, List<dynamic>) showOrderDetailsDialog;
  final int index;
  final bool isSelected;
  final bool isAdmin;
  const AdminCurrentCard({
    super.key,
    required this.order,
    required this.showOrderDetailsDialog,
    required this.index,
    required this.isSelected,
    required this.isAdmin,
  });

  @override
  State<AdminCurrentCard> createState() => _AdminCurrentCardState();
}

class _AdminCurrentCardState extends State<AdminCurrentCard> {
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
    final userProv = Provider.of<UserProvider>(context);

    final name =
        userProv.allUsers.firstWhere((e) => e.uid == widget.order.uid).name;

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
                if (widget.isAdmin) _buildOrderItems(name, "Name"),
                _buildOrderItems("#${widget.order.orderNo}", "Order ID"),
                _buildOrderItems(widget.order.status, "Status"),
                _buildOrderItems(
                    formatUnixDate(widget.order.orderDateTime), "Order Date"),
                if (widget.order.status == "Pending") ...[
                  _buildOrderItems(
                      formatUnixTime(widget.order.orderDateTime), "Order Time"),
                ],
                _buildOrderItems(
                    '₹ ${widget.order.totalAmount}', "Total Amount"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
