import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/constants/utils.dart';
import 'package:sss_retail/models/item_model.dart';
import 'package:sss_retail/models/order_model.dart';
import 'package:sss_retail/models/user_model.dart';
import 'package:sss_retail/providers/order_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/admin_current_card.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';
import 'package:path_provider/path_provider.dart';

class CurrentOrderAdmin extends StatefulWidget {
  const CurrentOrderAdmin({super.key});

  @override
  State<CurrentOrderAdmin> createState() => _CurrentOrderAdminState();
}

class _CurrentOrderAdminState extends State<CurrentOrderAdmin> {
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
    itemProv.getAllOrders();
    itemProv.getAllUsers();
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  // List<OrderModel> _filterItems(List<OrderModel> orders) {
  //   if (searchQuery.isEmpty) return orders;
  //   return orders
  //       .where((order) =>
  //           order.oid.toLowerCase().contains(searchQuery.toLowerCase()))
  //       .toList();
  // }

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

  Future<void> generateSeparateExcelFiles(
    List<OrderModel> orders,
    List<ItemModel> allItems,
    List<UserModel> users,
    String dateTime,
  ) async {
    try {
      List<ItemModel> dryItems =
          allItems.where((item) => item.itemType == 'Dry').toList();
      List<ItemModel> wetItems =
          allItems.where((item) => item.itemType == 'Wet').toList();

      await _generateExcelFile(orders, dryItems, wetItems,
          'Dry_Items_Summary.xlsx', users, dateTime);
    } catch (e) {
      print('Failed to generate Excel files: $e');
    }
  }

  Future<void> _generateExcelFile(
    List<OrderModel> orders,
    List<ItemModel> dryitems,
    List<ItemModel> wetitems,
    String fileName,
    List<UserModel> users,
    String dateTime,
  ) async {
    var excel = Excel.createExcel();
    var excel2 = Excel.createExcel();
    Sheet sheetObject = excel[excel.getDefaultSheet()!];
    Sheet sheetObject2 = excel2[excel2.getDefaultSheet()!];

    DateTime now = DateTime.fromMillisecondsSinceEpoch(int.parse(dateTime));
    DateTime headerDate = now.hour < 19 ? now : now.add(Duration(days: 1));
    String headerDateString =
        '${headerDate.day}-${headerDate.month}-${headerDate.year}';

    List<CellValue> headerRow = [
      TextCellValue(headerDateString),
    ];
    List<CellValue> headerRow2 = [TextCellValue(headerDateString)];

    for (var order in orders) {
      final name = users.firstWhere((e) => e.uid == order.uid).name;
      if (!headerRow.contains(TextCellValue(name))) {
        headerRow.add(TextCellValue(name));
      }
    }
    headerRow.add(TextCellValue('Total Qty'));
    headerRow.add(TextCellValue('Total Price'));

    sheetObject.appendRow(headerRow);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = CellStyle(bold: true);

    for (var item in dryitems) {
      List<CellValue> row = [TextCellValue(item.itemName)];
      int totalQty = 0;
      double totalPrice = 0;

      for (var order in orders) {
        int itemQty = 0;

        for (var orderItem in order.orderItems) {
          if (orderItem.keys.first == item.itemId) {
            itemQty = orderItem.values.first as int;
            break;
          }
        }

        totalQty += itemQty;
        totalPrice += itemQty * item.itemPrice;
        row.add(IntCellValue(itemQty));
      }

      row.add(IntCellValue(totalQty));
      row.add(DoubleCellValue(totalPrice));
      sheetObject.appendRow(row);
    }

    sheetObject2
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = CellStyle(bold: true);

    for (var order in orders) {
      final name = users.firstWhere((e) => e.uid == order.uid).name;
      if (!headerRow2.contains(TextCellValue(name))) {
        headerRow2.add(TextCellValue(name));
      }
    }
    headerRow2.add(TextCellValue('Total Qty'));
    headerRow2.add(TextCellValue('Total Price'));
    sheetObject2.appendRow(headerRow2);

    for (var item in wetitems) {
      List<CellValue> row = [TextCellValue(item.itemName)];
      int totalQty = 0;
      double totalPrice = 0;

      for (var order in orders) {
        int itemQty = 0;

        for (var orderItem in order.orderItems) {
          if (orderItem.keys.first == item.itemId) {
            itemQty = orderItem.values.first as int;
            break;
          }
        }

        totalQty += itemQty;
        totalPrice += itemQty * item.itemPrice;
        row.add(IntCellValue(itemQty));
      }

      row.add(IntCellValue(totalQty));
      row.add(DoubleCellValue(totalPrice));
      sheetObject2.appendRow(row);
    }

    Directory? directory = await getTemporaryDirectory();
    String filePath =
        '${directory.path}/Current_Dry_Orders_${now.toIso8601String()}.xlsx';
    String filePath2 =
        '${directory.path}/Current_Wet_Orders_${now.toIso8601String()}.xlsx';
    File file = File(filePath);
    File file2 = File(filePath2);
    final excelSheet = excel.save()!;
    final excelSheet2 = excel2.save()!;
    file.writeAsBytesSync(excelSheet);
    file2.writeAsBytesSync(excelSheet2);

    final Email email = Email(
      body: 'Please find the current orders attached as an Excel file.',
      subject: 'Order Delivery Date ${formatUnixDate(dateTime)}',
      recipients: ['sssenterprises2013@yahoo.in'],
      attachmentPaths: [filePath, filePath2],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);

    print('Excel file generated: $filePath');
  }

  void confirmAndCompleteOrders(List<OrderModel> allOrders) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Completion"),
          content: Text(
            "Are you sure you want to mark ${allOrders.length} orders as completed?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                Navigator.of(context).pop();
                final orderProv =
                    Provider.of<OrderProvider>(context, listen: false);

                for (var order in allOrders) {
                  await orderProv.editOrderStatus(order.oid, "Completed");
                }

                await Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    isLoading = false;
                  });
                  getAllOrders();
                });
              },
              child: Text(
                "Confirm",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 21,
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

    List<OrderModel> pendingOrders =
        orderProv.allOrders.where((e) => e.status == 'Pending').toList();

    Map<String, List<OrderModel>> ordersByDeliveryDate = {};
    for (var order in pendingOrders) {
      final deliveryDate = order.deliveryDate;
      ordersByDeliveryDate.putIfAbsent(deliveryDate, () => []).add(order);
    }

    final sortedOrdersByDeliveryDate = Map.fromEntries(
      ordersByDeliveryDate.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    return Scaffold(
      appBar: CustomAppBar(title: "Current Orders"),
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
                    Gap(15),
                    Expanded(
                      child: sortedOrdersByDeliveryDate.isEmpty
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
                              itemCount: sortedOrdersByDeliveryDate.keys.length,
                              itemBuilder: (context, index) {
                                final date = sortedOrdersByDeliveryDate.keys
                                    .toList()[index];
                                final orders =
                                    sortedOrdersByDeliveryDate[date]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Delivery: ${formatUnixDate(date)}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              confirmAndCompleteOrders(orders);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                side: BorderSide(
                                                  width: 3,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'Complete',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...orders.map(
                                      (order) => AdminCurrentCard(
                                        showOrderDetailsDialog:
                                            showOrderDetailsDialog,
                                        order: order,
                                        index: pendingOrders.indexOf(order),
                                        isSelected: selectedIndex != null &&
                                            pendingOrders.indexOf(order) ==
                                                selectedIndex,
                                        isAdmin: true,
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          top: 6,
                                          bottom: 18),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await generateSeparateExcelFiles(
                                            orders,
                                            orderProv.allItems,
                                            orderProv.allUsers,
                                            date,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                        child: Text(
                                          'Email Orders',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
