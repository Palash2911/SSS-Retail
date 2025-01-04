import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

      userOrderHistory.add(order);
      currOrderList.clear();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future editOrderStatus(OrderModel order) async {
    try {
      CollectionReference orderCollection =
          FirebaseFirestore.instance.collection('Orders');

      await orderCollection.doc(order.oid).update({
        "Status": order.status,
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

      List<OrderModel> pendingOrders = [];
      List<OrderModel> otherOrders = [];

      for (var element in orderData.docs) {
        final order = OrderModel(
          oid: element.id,
          uid: element['UID'] ?? '',
          orderItems: element['Items'] ?? [],
          orderDateTime: element['OrderDateTime'] ?? '',
          status: element['Status'] ?? '',
          totalAmount: element['TotalAmount'] ?? 0,
        );

        if (element['Status'] == 'Pending') {
          pendingOrders.add(order);
        } else {
          otherOrders.add(order);
        }
      }

      userOrderHistory
        ..addAll(pendingOrders)
        ..addAll(otherOrders);

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
