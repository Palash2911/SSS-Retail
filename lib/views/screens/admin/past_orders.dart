import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/order_model.dart';
import 'package:sss_retail/providers/order_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';
import 'package:sss_retail/views/components/order_history_card.dart';

class PastOrdersAdmin extends StatefulWidget {
  const PastOrdersAdmin({super.key});

  @override
  State<PastOrdersAdmin> createState() => _PastOrdersAdminState();
}

class _PastOrdersAdminState extends State<PastOrdersAdmin> {
  bool isLoading = true;
  int? selectedIndex;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    getAllOrders();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getAllOrders() async {
    final itemProv = Provider.of<UserProvider>(context, listen: false);
    itemProv.getAllItems();
    await itemProv.getAllOrders();
    itemProv.getAllUsers();
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<OrderModel> _filterItems(List<OrderModel> orders) {
    if (searchQuery.isEmpty) return orders;
    return orders
        .where((order) =>
            order.oid.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void showOrderDetailsDialog(int selectIndex, List<dynamic> orders) {
    setState(() {
      selectedIndex = selectIndex;
    });
    final itemProv = Provider.of<UserProvider>(context, listen: false);

    List<Map<String, dynamic>> orderDetails = [];

    for (var item in orders) {
      var matchingItem = itemProv.allItems
          .firstWhere((element) => element.itemId == item.keys.first);

      int totalPrice = matchingItem.itemPrice * item.values.first as int;

      orderDetails.add({
        'item_name': matchingItem.itemName,
        'item_qty': item.values.first,
        'price': totalPrice,
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            height: 270.h,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Text(
                      'Order Details:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    children: orderDetails.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                item['item_name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              'Qty: ${item['item_qty']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '₹${item['price']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: EdgeInsets.only(bottom: 9, right: 9),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedIndex = null;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showCancelOrderDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to cancel order?',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });
                final orderProv =
                    Provider.of<OrderProvider>(context, listen: false);
                await orderProv.editOrderStatus(id, 'Cancelled');

                Fluttertoast.showToast(
                  msg: 'Order Cancelled Successfully :(',
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );

                getAllOrders();
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<UserProvider>(context);

    List<OrderModel> filterOrders = _filterItems(
        orderProv.allOrders.where((e) => e.status != 'Pending').toList());

    return Scaffold(
      appBar: CustomAppBar(title: "Order History"),
      body: isLoading
          ? CustomLoader()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                await getAllOrders();
              },
              color: AppColors.accentColor2,
              backgroundColor: Colors.white,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search Order ID',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    Gap(15),
                    Expanded(
                      child: filterOrders.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty
                                    ? "No Orders Found !!"
                                    : "No Matching Order ID Found",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 21),
                              itemCount: filterOrders.length,
                              itemBuilder: (context, index) {
                                return OrderHistoryCard(
                                  showOrderDetailsDialog:
                                      showOrderDetailsDialog,
                                  order: filterOrders[index],
                                  index: index,
                                  isSelected: selectedIndex != null &&
                                      index == selectedIndex,
                                  cancelOrder: showCancelOrderDialog,
                                  isAdmin: true,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
