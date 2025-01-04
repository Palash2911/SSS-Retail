import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sss_retail/models/item_model.dart';

class ItemProvider extends ChangeNotifier {
  Future addItem(ItemModel item) async {
    try {
      CollectionReference itemCollection =
          FirebaseFirestore.instance.collection('Items');

      await itemCollection.doc().set({
        "Name": item.itemName,
        "Price": item.itemPrice,
        "Type": item.itemType,
        "ParentItemID": item.parentItemId,
        "Order": item.itemOrder,
      });

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future updateItem(ItemModel item) async {
    try {
      CollectionReference itemCollection =
          FirebaseFirestore.instance.collection('Items');

      await itemCollection.doc(item.itemId).update({
        "Name": item.itemName,
        "Price": item.itemPrice,
        "Type": item.itemType,
        "ParentItemID": item.parentItemId,
        "Order": item.itemOrder,
      });

      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
