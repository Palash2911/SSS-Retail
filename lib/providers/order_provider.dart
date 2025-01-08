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
        "TotalAmount": order.totalAmount.toString(),
        "OrderItems": order.orderItems,
        "OrderNo": order.orderNo,
        "DeliveryDate": order.deliveryDate,
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
          orderDateTime: element['OrderDateTime'] ?? '',
          status: element['Status'] ?? '',
          totalAmount: double.parse(element['TotalAmount'].toString()),
          orderNo: element['OrderNo'] ?? 0,
          deliveryDate: element['DeliveryDate'] ?? '',
        );

        userOrderHistory.add(order);
      }

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
