import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sss_retail/models/item_model.dart';
import 'package:sss_retail/models/order_model.dart';
import 'package:sss_retail/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> allUsers = [];
  List<OrderModel> allOrders = [];
  List<ItemModel> allItems = [];
  UserModel currUser = UserModel(
    uid: '',
    name: '',
    phone: '',
    dealerShipName: '',
    lastOrderId: '',
    isAdmin: false,
  );

  Future registerUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('Users');

      await userCollection.doc(user.uid).set({
        "Name": user.name,
        "Contact": user.phone,
        "UID": user.uid,
        "DealerShipName": user.dealerShipName,
        "LastOrderID": user.lastOrderId,
        "IsAdmin": user.isAdmin,
      });

      prefs.setString("UserName", user.name);
      prefs.setString("DealerShipName", user.dealerShipName);
      prefs.setString('PhoneNo', user.phone);
      prefs.setBool("IsAdmin", user.isAdmin);
      notifyListeners();
    } catch (e) {
      prefs.setString("UserName", "");
      prefs.setString("DealerShipName", "");
      prefs.setString('PhoneNo', "");
      prefs.setBool("IsAdmin", false);

      notifyListeners();
      rethrow;
    }
  }

  void getUser(String uid, bool isAdmin, String phoneNo) async {
    try {
      if (uid.isEmpty) return;
      if (isAdmin) {
        final adminShot = await FirebaseFirestore.instance
            .collection('Users')
            .where('Contact', isEqualTo: phoneNo)
            .limit(1)
            .get();

        if (adminShot.docs.isNotEmpty) {
          final adminSnapshot = adminShot.docs.first;
          currUser = UserModel(
            uid: uid,
            name: adminSnapshot['Name'],
            phone: adminSnapshot['Contact'],
            dealerShipName: adminSnapshot['DealerShipName'],
            lastOrderId: adminSnapshot['LastOrderID'],
            isAdmin: adminSnapshot['IsAdmin'],
          );
        }
      } else {
        DocumentSnapshot userSnapShot =
            await FirebaseFirestore.instance.collection('Users').doc(uid).get();

        currUser = UserModel(
          uid: uid,
          name: userSnapShot['Name'],
          phone: userSnapShot['Contact'],
          dealerShipName: userSnapShot['DealerShipName'],
          lastOrderId: userSnapShot['LastOrderID'],
          isAdmin: userSnapShot['IsAdmin'],
        );
      }
      notifyListeners();
    } catch (e) {
      notifyListeners();
      throw Exception("Failed to fetch data $e");
    }
  }

  Future updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('Users');

      await userCollection.doc(user.uid).update({
        "Name": user.name,
        "Contact": user.phone,
        "UID": user.uid,
        "DealerShipName": user.dealerShipName,
        "LastOrderID": user.lastOrderId,
        "IsAdmin": user.isAdmin,
      });

      prefs.setString("UserName", user.name);
      prefs.setString("DealerShipName", user.dealerShipName);
      prefs.setString('PhoneNo', user.phone);
      prefs.setBool("IsAdmin", user.isAdmin);
      currUser.dealerShipName = user.dealerShipName;
      currUser.name = user.name;
      currUser.phone = user.phone;

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getAllUsers() async {
    try {
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('Users');

      final userData = await userCollection.get();
      allUsers.clear();
      userData.docs.forEach((element) {
        allUsers.add(
          UserModel(
            uid: element.id,
            name: element['Name'] ?? '',
            phone: element['Contact'] ?? '',
            dealerShipName: element['DealerShipName'] ?? '',
            lastOrderId: element['LastOrderID'] ?? '',
            isAdmin: element['IsAdmin'] ?? false,
          ),
        );
      });
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getAllOrders() async {
    try {
      CollectionReference orderCollection =
          FirebaseFirestore.instance.collection('Orders');

      final orderData = await orderCollection.get();
      allOrders.clear();
      orderData.docs.forEach((element) {
        allOrders.add(
          OrderModel(
            oid: element.id,
            uid: element['UID'] ?? '',
            orderItems: element['OrderItems'] ?? [],
            orderDateTime: element['OrderDateTime'] ?? '',
            status: element['Status'] ?? '',
            totalAmount: double.parse(element['TotalAmount'].toString()),
            orderNo: element['OrderNo'] ?? 0,
            deliveryDate: element['DeliveryDate'] ?? '',
          ),
        );
      });
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getAllItems() async {
    try {
      CollectionReference itemsCollection =
          FirebaseFirestore.instance.collection('Items');

      final itemData = await itemsCollection.get();
      allItems.clear();
      itemData.docs.forEach((element) {
        allItems.add(
          ItemModel(
            itemId: element.id,
            itemName: element['Name'] ?? '',
            itemPrice: double.parse(element['Price'].toString()),
            itemType: element['Type'] ?? '',
            parentItemId: element['ParentItemID'] ?? '',
            itemOrder: element['Order'] ?? 0,
          ),
        );
      });

      allItems.sort((a, b) => a.itemOrder.compareTo(b.itemOrder));

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
