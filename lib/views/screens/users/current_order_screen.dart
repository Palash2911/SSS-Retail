import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/item_model.dart';
import 'package:sss_retail/providers/order_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';
import 'package:sss_retail/views/components/item_card.dart';
import 'package:sss_retail/views/screens/users/cart_screen.dart';

class CurrentOrderScreen extends StatefulWidget {
  const CurrentOrderScreen({super.key});

  @override
  State<CurrentOrderScreen> createState() => _CurrentOrderScreenState();
}

class _CurrentOrderScreenState extends State<CurrentOrderScreen> {
  bool isLoading = true;
  int? selectedIndex;
  String searchQuery = '';
  String _foodType = 'Dry';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    getAllItems();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getAllItems() async {
    final itemProv = Provider.of<UserProvider>(context, listen: false);
    await itemProv.getAllItems();
    Future.delayed(Duration(milliseconds: 1800), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<ItemModel> _filterItems(List<ItemModel> items) {
    if (searchQuery.isEmpty) return items;
    return items
        .where((item) =>
            item.itemName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void showModal(String parentId) {
    final itemProv = Provider.of<UserProvider>(context, listen: false);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    var filteredItems = itemProv.allItems
        .where((item) => item.parentItemId == parentId)
        .toList();

    if (filteredItems.isEmpty) {
      filteredItems =
          itemProv.allItems.where((item) => item.itemId == parentId).toList();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double itemHeight = 70;
            double calculatedHeight = (filteredItems.length * itemHeight) + 150;
            double modalHeight =
                calculatedHeight > 450 ? 450 : calculatedHeight;

            return Container(
              height: modalHeight,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Items",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(15),
                  filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            "No items found for this category",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isInCart =
                                  orderProv.currOrderList.isNotEmpty &&
                                      orderProv.currOrderList.any((order) =>
                                          order['itemId'] == item.itemId);

                              final TextEditingController quantityController =
                                  TextEditingController(
                                text: isInCart
                                    ? '${orderProv.currOrderList.firstWhere((order) => order['itemId'] == item.itemId)['quantity']}'
                                    : '0',
                              );

                              quantityController.addListener(() {
                                final newQty =
                                    int.tryParse(quantityController.text) ?? 0;
                                if (isInCart) {
                                  if (newQty >= 0) {
                                    orderProv.modifyOrderQty(
                                        item.itemId, newQty);
                                  }
                                } else {
                                  orderProv.addOrder(
                                    {
                                      'itemId': item.itemId,
                                      'itemName': item.itemName,
                                      'quantity': newQty,
                                      'price': item.itemPrice,
                                    },
                                  );
                                }
                              });

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 9),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            color: AppColors.primary),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove,
                                                color: AppColors.primary),
                                            onPressed: () {
                                              if (!isInCart) return;
                                              setState(() {
                                                final order = orderProv
                                                    .currOrderList
                                                    .firstWhere((order) =>
                                                        order['itemId'] ==
                                                        item.itemId);
                                                if (order['quantity'] > 1) {
                                                  orderProv.modifyOrderQty(
                                                    item.itemId,
                                                    order['quantity'] - 1,
                                                  );
                                                } else {
                                                  orderProv.removeOrder(order);
                                                }
                                              });
                                            },
                                          ),
                                          // Text(
                                          //   !isInCart
                                          //       ? '0'
                                          //       : '${orderProv.currOrderList.firstWhere((order) => order['itemId'] == item.itemId)['quantity']}',
                                          //   style: TextStyle(
                                          //     fontSize: 18,
                                          //     fontWeight: FontWeight.w600,
                                          //   ),
                                          // ),
                                          SizedBox(
                                            width: 36,
                                            child: TextField(
                                              controller: quantityController,
                                              textAlign: TextAlign.center,
                                              textInputAction: index ==
                                                      filteredItems.length - 1
                                                  ? TextInputAction.done
                                                  : TextInputAction.next,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 0),
                                              ),
                                              onSubmitted: (value) {
                                                if (index ==
                                                    filteredItems.length - 1) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add,
                                                color: AppColors.primary),
                                            onPressed: () {
                                              if (!isInCart) {
                                                orderProv.addOrder(
                                                  {
                                                    'itemId': item.itemId,
                                                    'itemName': item.itemName,
                                                    'quantity': 1,
                                                    'price': item.itemPrice,
                                                  },
                                                );
                                              } else {
                                                orderProv.modifyOrderQty(
                                                    item.itemId,
                                                    orderProv.currOrderList
                                                                .firstWhere((order) =>
                                                                    order[
                                                                        'itemId'] ==
                                                                    item.itemId)[
                                                            'quantity'] +
                                                        1);
                                              }
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProv = Provider.of<UserProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    List<ItemModel> filteredItems = _filterItems(itemProv.allItems
        .where((e) => e.itemType == _foodType && e.parentItemId.isEmpty)
        .toList());

    return Scaffold(
      appBar: CustomAppBar(title: "SSS Retail"),
      body: isLoading
          ? CustomLoader()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                await getAllItems();
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
                          hintText: 'Search $_foodType Foods...',
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
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              'Dry',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            leading: Transform.scale(
                              scale: 1.2,
                              child: Radio<String>(
                                activeColor: AppColors.primary,
                                value: 'Dry',
                                groupValue: _foodType,
                                onChanged: (String? value) {
                                  setState(() {
                                    _foodType = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              'Wet',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            leading: Transform.scale(
                              scale: 1.2,
                              child: Radio<String>(
                                activeColor: AppColors.primary,
                                value: 'Wet',
                                groupValue: _foodType,
                                onChanged: (String? value) {
                                  setState(() {
                                    _foodType = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty
                                    ? "No $_foodType Food Found !!"
                                    : "No Matching $_foodType Food Found",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 81),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                return ItemCard(
                                  itemName: filteredItems[index].itemName,
                                  itemId: filteredItems[index].itemId,
                                  showModel: showModal,
                                );
                              },
                            ),
                    ),
                    orderProv.currOrderList.isEmpty
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 9),
                              padding: EdgeInsets.symmetric(
                                  vertical: 11, horizontal: 15),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "View Cart",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart,
                                        color: Colors.white,
                                        size: 27,
                                      ),
                                      Gap(15),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 27,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
    );
  }
}
