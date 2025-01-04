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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isOrderPlaced = false;
  bool isLoading = false;

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
    setState(() {
      isLoading = true;
    });
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final authProv = Provider.of<Auth>(context, listen: false);
    final orderItems = orderProv.currOrderList.map((item) {
      return {item['itemId']: item['quantity']};
    }).toList();

    final totalPrice = orderProv.currOrderList.fold<int>(
      0,
      (sum, item) => sum + (item['price'] * item['quantity'] as int),
    );

    await orderProv.placeOrder(
      OrderModel(
        oid: '',
        uid: authProv.token,
        status: "Pending",
        totalAmount: totalPrice,
        orderItems: orderItems,
        orderDateTime: '',
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        isOrderPlaced = true;
      });
    });
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Gap(18),
                      ListView.builder(
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
