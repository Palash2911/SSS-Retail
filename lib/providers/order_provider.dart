import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sss_retail/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> userOrderHistory = [];
  List<dynamic> currOrderList = [];

  void addOrder(Map<dynamic, dynamic> order) async {
    try {
      currOrderList.add(order);
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  void removeOrder(Map<dynamic, dynamic> order) async {
    try {
      currOrderList.remove(order);
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  void modifyOrderQty(String id, int qty) async {
    try {
      int index =
          currOrderList.indexWhere((element) => element['itemId'] == id);

      if (index != -1) {
        currOrderList[index]['quantity'] = qty;
      }

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> placeOrder(OrderModel order) async {
    try {
      CollectionReference orderCollection =
          FirebaseFirestore.instance.collection('Orders');

      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('Users');

      DocumentReference newOrderDoc = orderCollection.doc();

      await newOrderDoc.set({
        "UID": order.uid,
        "OrderDateTime": DateTime.now().millisecondsSinceEpoch.toString(),
        "Status": order.status,
        "TotalAmount": order.totalAmount,
        "OrderItems": order.orderItems,
      });

      await userCollection.doc(order.uid).update({
        "LastOrderID": newOrderDoc.id,
      });

      order.oid = newOrderDoc.id;

      userOrderHistory.add(order);
      currOrderList.clear();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future editOrderStatus(String oid, String status) async {
    try {
      CollectionReference orderCollection =
          FirebaseFirestore.instance.collection('Orders');

      await orderCollection.doc(oid).update({
        "Status": status,
      });

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getOrderHistory(String uid) async {
    try {
      CollectionReference orderCollection =
          FirebaseFirestore.instance.collection('Orders');

      final orderData = await orderCollection
          .where('UID', isEqualTo: uid)
          .orderBy('OrderDateTime', descending: true)
          .get();

      userOrderHistory.clear();

      for (var element in orderData.docs) {
        final order = OrderModel(
          oid: element.id,
          uid: element['UID'] ?? '',
          orderItems: element['OrderItems'] ?? [],
          orderDateTime: formatUnixDate(element['OrderDateTime'] ?? ''),
          status: element['Status'] ?? '',
          totalAmount: element['TotalAmount'] ?? 0,
        );

        userOrderHistory.add(order);
      }

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

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
}
