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

Future<void> generateSeparateExcelFiles(
  List<OrderModel> orders,
  List<ItemModel> allItems,
  List<UserModel> users,
  String dateTime,
) async {
  try {
    List<ItemModel> dryItems = allItems
        .where((item) => item.itemType == 'Dry' && item.itemPrice != 0.0)
        .toList()
      ..sort((a, b) {
        if (a.parentItemId.isEmpty && b.parentItemId.isNotEmpty) {
          return -1;
        } else if (a.parentItemId.isNotEmpty && b.parentItemId.isEmpty) {
          return 1;
        } else {
          return a.parentItemId.compareTo(b.parentItemId);
        }
      });

    List<ItemModel> wetItems = allItems
        .where((item) => item.itemType == 'Wet' && item.itemPrice != 0.0)
        .toList()
      ..sort((a, b) {
        if (a.parentItemId.isEmpty && b.parentItemId.isNotEmpty) {
          return -1;
        } else if (a.parentItemId.isNotEmpty && b.parentItemId.isEmpty) {
          return 1;
        } else {
          return a.parentItemId.compareTo(b.parentItemId);
        }
      });

    List<ItemModel> horecaItems = allItems
        .where((item) => item.itemType == 'Horeca' && item.itemPrice != 0.0)
        .toList()
      ..sort((a, b) {
        if (a.parentItemId.isEmpty && b.parentItemId.isNotEmpty) {
          return -1;
        } else if (a.parentItemId.isNotEmpty && b.parentItemId.isEmpty) {
          return 1;
        } else {
          return a.parentItemId.compareTo(b.parentItemId);
        }
      });

    List<ItemModel> deliteItems = allItems
        .where((item) => item.itemType == 'Delite' && item.itemPrice != 0.0)
        .toList()
      ..sort((a, b) {
        if (a.parentItemId.isEmpty && b.parentItemId.isNotEmpty) {
          return -1;
        } else if (a.parentItemId.isNotEmpty && b.parentItemId.isEmpty) {
          return 1;
        } else {
          return a.parentItemId.compareTo(b.parentItemId);
        }
      });

    await _generateExcelFile(
        orders, dryItems, wetItems, horecaItems, deliteItems, users, dateTime);
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

  final excelFiles = await Future.wait([
    _generateCategoryExcel(
        'Dry', dryItems, orders, users, headerDateString, now),
    _generateCategoryExcel(
        'Wet', wetItems, orders, users, headerDateString, now),
    _generateCategoryExcel(
        'Horeca', horecaItems, orders, users, headerDateString, now),
    _generateCategoryExcel(
        'Delite', deliteItems, orders, users, headerDateString, now),
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
    headerRow.add(TextCellValue(user.name));
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
