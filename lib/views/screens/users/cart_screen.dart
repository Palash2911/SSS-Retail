import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/order_model.dart';
import 'package:sss_retail/providers/auth_provider.dart';
import 'package:sss_retail/providers/order_provider.dart';
import 'package:sss_retail/views/components/cart_card.dart';
import 'package:sss_retail/views/components/cart_summary_card.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';
import 'package:sss_retail/views/components/date_picker.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isOrderPlaced = false;
  bool isLoading = false;
  int ono = 0;
  // String _orderType = 'Today';

  void removeItem(int index) {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    orderProv.removeOrder(orderProv.currOrderList[index]);
    setState(() {});
  }

  void modifyOrder(String itemId, int qty) {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    setState(() {
      final order = orderProv.currOrderList
          .firstWhere((order) => order['itemId'] == itemId);
      if (order['quantity'] > 1) {
        orderProv.modifyOrderQty(
          itemId,
          qty,
        );
      } else {
        orderProv.removeOrder(order);
      }
    });
  }

  void placeOrder() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select delivery date !',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          duration: Duration(milliseconds: 1200),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final authProv = Provider.of<Auth>(context, listen: false);
    final orderItems = orderProv.currOrderList.map((item) {
      return {item['itemId']: item['quantity']};
    }).toList();

    ono = int.parse(
        DateTime.now().millisecondsSinceEpoch.toString().substring(9, 13));

    final totalPrice = orderProv.currOrderList.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );

    await orderProv.placeOrder(
      OrderModel(
        oid: '',
        uid: authProv.token,
        status: "Pending",
        totalAmount: totalPrice,
        orderItems: orderItems,
        orderDateTime: '',
        orderNo: ono,
        deliveryDate: selectedDate!.millisecondsSinceEpoch.toString(),
      ),
    );

    await orderProv.getOrderHistory(authProv.token);

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        isOrderPlaced = true;
      });
    });
  }

  DateTime? selectedDate;

  void _selectDate() async {
    final now = DateTime.now();
    final isAfter6PM = now.hour >= 18;

    final initialDate =
        isAfter6PM ? now.add(Duration(days: 2)) : now.add(Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: now.add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: "Cart Summary"),
      body: isLoading
          ? CustomLoader()
          : orderProv.currOrderList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Gap(120.w),
                      Image.asset(
                        'assets/cart_lottie.gif',
                      ),
                      Text(
                        isOrderPlaced ? "Order Placed :)" : "Cart is empty !!",
                        style: TextStyle(
                          fontSize: 27,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isOrderPlaced) ...[
                        Gap(21),
                        Text(
                          "Order ID: #$ono",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(40),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 120.w,
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                            child: Center(
                              child: Text(
                                "Go Back",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.accentColor2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Gap(18),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: ListTile(
                      //         title: const Text(
                      //           'Today',
                      //           style: TextStyle(
                      //             fontSize: 19,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.black87,
                      //           ),
                      //         ),
                      //         leading: Transform.scale(
                      //           scale: 1.2,
                      //           child: Radio<String>(
                      //             activeColor: AppColors.primary,
                      //             value: 'Today',
                      //             groupValue: _orderType,
                      //             onChanged: (String? value) {
                      //               setState(() {
                      //                 _orderType = value!;
                      //               });
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: ListTile(
                      //         title: const Text(
                      //           'Schedule',
                      //           style: TextStyle(
                      //             fontSize: 19,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.black87,
                      //           ),
                      //         ),
                      //         leading: Transform.scale(
                      //           scale: 1.2,
                      //           child: Radio<String>(
                      //             activeColor: AppColors.primary,
                      //             value: 'Schedule',
                      //             groupValue: _orderType,
                      //             onChanged: (String? value) {
                      //               setState(() {
                      //                 _orderType = value!;
                      //               });
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Gap(6),
                      ScheduleOrderWidget(
                        selectedDate: selectedDate,
                        onDateSelected: _selectDate,
                      ),
                      Gap(7),
                      // if (_orderType == 'Schedule') ...[
                      // ],
                      Gap(6),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: orderProv.currOrderList.length,
                        itemBuilder: (context, index) {
                          return CartCard(
                            item: orderProv.currOrderList[index],
                            index: index,
                            removeItem: removeItem,
                            modifyOrder: modifyOrder,
                          );
                        },
                      ),
                      Gap(30),
                      CartSummaryCard(
                        filteredItems: orderProv.currOrderList,
                      ),
                      Gap(45),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 21),
                        width: double.infinity,
                        height: 49,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            placeOrder();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt,
                                color: Colors.white,
                                size: 25,
                              ),
                              Gap(11),
                              Text(
                                "Place Order",
                                style: TextStyle(
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(30),
                    ],
                  ),
                ),
    );
  }
}
