import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sss_retail/models/item_model.dart';
import 'package:sss_retail/models/order_model.dart';
import 'package:sss_retail/models/user_model.dart';

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String formatUnixDate(String dateU) {
  final dateInMilliseconds = int.parse(dateU);
  final date = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
  final formattedDate = DateFormat('d MMM, y').format(date);
  final daySuffix = getDaySuffix(date.day);
  final finalFormattedDate =
      '${date.day}$daySuffix ${formattedDate.substring(2)}';
  return finalFormattedDate;
}

String formatUnixTime(String unixTimestamp) {
  final dateInMilliseconds = int.parse(unixTimestamp);
  final dateTime = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
  final formattedTime = DateFormat('hh:mm a').format(dateTime);
  return formattedTime;
}

List<ItemModel> sortItems(List<ItemModel> items) {
  List<ItemModel> groupedItems = [];

  Map<String, List<ItemModel>> childGroups = {};

  for (var item in items) {
    if (item.parentItemId.isNotEmpty) {
      childGroups.putIfAbsent(item.parentItemId, () => []).add(item);
    }
  }

  childGroups.forEach((parentId, children) {
    children.sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
  });

  for (var item in items) {
    if (item.parentItemId.isEmpty) {
      groupedItems.add(item);

      if (childGroups.containsKey(item.itemId)) {
        groupedItems.addAll(childGroups[item.itemId]!);
        childGroups.remove(item.itemId);
      }
    }
  }

  for (var orphanChildren in childGroups.values) {
    groupedItems.addAll(orphanChildren);
  }
  return groupedItems;
}

Future<void> generateSeparateExcelFiles(
  List<OrderModel> orders,
  List<ItemModel> allItems,
  List<UserModel> users,
  String dateTime,
) async {
  try {
    List<ItemModel> dryItems = sortItems(
      allItems.where((item) => item.itemType == 'Dry').toList()
        ..sort(
          (a, b) => a.itemOrder.compareTo(b.itemOrder),
        ),
    );
    dryItems.removeWhere((e) => e.itemPrice == 0.0 && e.parentItemId.isEmpty);

    List<ItemModel> wetItems = sortItems(
      allItems.where((item) => item.itemType == 'Wet').toList()
        ..sort(
          (a, b) => a.itemOrder.compareTo(b.itemOrder),
        ),
    );
    wetItems.removeWhere((e) => e.itemPrice == 0.0 && e.parentItemId.isEmpty);

    List<ItemModel> horecaItems = sortItems(
      allItems.where((item) => item.itemType == 'Horeca').toList()
        ..sort(
          (a, b) => a.itemOrder.compareTo(b.itemOrder),
        ),
    );
    horecaItems
        .removeWhere((e) => e.itemPrice == 0.0 && e.parentItemId.isEmpty);

    List<ItemModel> deliteItems = sortItems(
      allItems.where((item) => item.itemType == 'Delite').toList()
        ..sort(
          (a, b) => a.itemOrder.compareTo(b.itemOrder),
        ),
    );
    deliteItems
        .removeWhere((e) => e.itemPrice == 0.0 && e.parentItemId.isEmpty);

    await _generateExcelFile(
      orders,
      dryItems,
      wetItems,
      horecaItems,
      deliteItems,
      users,
      dateTime,
    );
  } catch (e) {
    print('Failed to generate Excel files: $e');
  }
}

Future<void> _generateExcelFile(
  List<OrderModel> orders,
  List<ItemModel> dryItems,
  List<ItemModel> wetItems,
  List<ItemModel> horecaItems,
  List<ItemModel> deliteItems,
  List<UserModel> users,
  String dateTime,
) async {
  final now = DateTime.fromMillisecondsSinceEpoch(int.parse(dateTime));
  final headerDate = now.hour < 19 ? now : now.add(Duration(days: 1));
  final headerDateString =
      '${headerDate.day}-${headerDate.month}-${headerDate.year}';

  List<OrderModel> dryOrders = orders.where((order) {
    return order.orderItems.any((item) {
      final itemo = item as Map;
      return dryItems.any((dryItem) => dryItem.itemId == itemo.keys.first);
    });
  }).toList();
  List<OrderModel> wetOrders = orders.where((order) {
    return order.orderItems.any((item) {
      final itemo = item as Map;
      return wetItems.any((wetIt) => wetIt.itemId == itemo.keys.first);
    });
  }).toList();
  List<OrderModel> horecaOrders = orders.where((order) {
    return order.orderItems.any((item) {
      final itemo = item as Map;
      return horecaItems.any((horecaIt) => horecaIt.itemId == itemo.keys.first);
    });
  }).toList();
  List<OrderModel> deliteOrders = orders.where((order) {
    return order.orderItems.any((item) {
      final itemo = item as Map;
      return deliteItems.any((deliteIt) => deliteIt.itemId == itemo.keys.first);
    });
  }).toList();

  final excelFiles = await Future.wait([
    _generateCategoryExcel(
      'Dry',
      dryItems,
      dryOrders,
      users,
      headerDateString,
      now,
    ),
    _generateCategoryExcel(
      'Wet',
      wetItems,
      wetOrders,
      users,
      headerDateString,
      now,
    ),
    _generateCategoryExcel(
      'Horeca',
      horecaItems,
      horecaOrders,
      users,
      headerDateString,
      now,
    ),
    _generateCategoryExcel(
      'Delite',
      deliteItems,
      deliteOrders,
      users,
      headerDateString,
      now,
    ),
  ]);

  final email = Email(
    body: 'Please find the current orders attached as an Excel file.',
    subject: 'Order Delivery Date ${formatUnixDate(dateTime)}',
    recipients: ['sssenterprises2013@yahoo.in'],
    attachmentPaths: excelFiles,
    isHTML: false,
  );

  await FlutterEmailSender.send(email);
}

Future<String> _generateCategoryExcel(
  String category,
  List<ItemModel> items,
  List<OrderModel> orders,
  List<UserModel> users,
  String headerDateString,
  DateTime now,
) async {
  final excel = Excel.createExcel();
  final sheet = excel[excel.getDefaultSheet()!];

  final headerRow = [TextCellValue(headerDateString)];
  final uniqueUsers = orders
      .map((order) => users.firstWhere((e) => e.uid == order.uid))
      .toSet()
      .toList();

  for (var user in uniqueUsers) {
    headerRow.add(TextCellValue(user.dealerShipName));
  }
  headerRow.addAll([TextCellValue('Total Qty'), TextCellValue('Total Price')]);

  sheet.appendRow(headerRow);
  sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      .cellStyle = CellStyle(bold: true);

  for (int i = 0; i < headerRow.length; i++) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
    cell.cellStyle = CellStyle(
        horizontalAlign:
            i == 0 ? HorizontalAlign.Left : HorizontalAlign.Center);
    sheet.setColumnAutoFit(i);
  }

  for (var item in items) {
    List<CellValue> row = [TextCellValue(item.itemName)];
    int totalQty = 0;
    double totalPrice = 0;

    for (var user in uniqueUsers) {
      final userOrders = orders.where((order) => order.uid == user.uid);
      int userTotalQty = 0;

      for (var order in userOrders) {
        final itemQty = order.orderItems
            .firstWhere((oi) => oi.keys.first == item.itemId,
                orElse: () => {item.itemId: 0})
            .values
            .first as int;
        userTotalQty += itemQty;
      }

      totalQty += userTotalQty;
      totalPrice += userTotalQty * item.itemPrice;
      row.add(IntCellValue(userTotalQty));
    }

    row
      ..add(IntCellValue(totalQty))
      ..add(DoubleCellValue(totalPrice));
    sheet.appendRow(row);
    for (int i = 0; i < row.length; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: i, rowIndex: sheet.maxRows - 1))
              .cellStyle =
          CellStyle(
              horizontalAlign:
                  i == 0 ? HorizontalAlign.Left : HorizontalAlign.Center);
    }
  }

  final directory = await getTemporaryDirectory();
  final filePath =
      '${directory.path}/${category}_Orders_$headerDateString.xlsx';
  final file = File(filePath);
  file.writeAsBytesSync(excel.save()!);

  return filePath;
}
