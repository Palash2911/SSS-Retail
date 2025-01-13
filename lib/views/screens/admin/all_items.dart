import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/item_model.dart';
import 'package:sss_retail/providers/item_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/admin_item_card.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';
import 'package:sss_retail/views/screens/admin/add_item.dart';

class AllItemScreen extends StatefulWidget {
  const AllItemScreen({super.key});

  @override
  State<AllItemScreen> createState() => _AllItemScreenState();
}

class _AllItemScreenState extends State<AllItemScreen> {
  bool isLoading = true;
  int? selectedIndex;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _foodType = 'Dry';

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
    Future.delayed(Duration(milliseconds: 1800), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<ItemModel> _filterItems(List<ItemModel> items) {
    if (searchQuery.isEmpty) return items;
    return items
        .where((order) =>
            order.itemName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            order.itemId.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void updateItem(String id) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddItem(type: "Update", id: id),
      ),
    )
        .then((_) {
      setState(() {
        isLoading = true;
      });
      getAllOrders();
    });
  }

  void showDeleteItemDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete item?',
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
                final itemProv =
                    Provider.of<ItemProvider>(context, listen: false);
                await itemProv.deleteItem(id);

                Fluttertoast.showToast(
                  msg: 'Item Deleted Successfully :(',
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
    final itemProv = Provider.of<UserProvider>(context);

    List<ItemModel> filterItems = _filterItems(
        itemProv.allItems.where((e) => e.itemType == _foodType).toList());

    return Scaffold(
      appBar: CustomAppBar(title: "All Items"),
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
                          hintText: 'Search Item Name or ID...',
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
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.0,
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
                                const Text(
                                  'Dry',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Gap(5),
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.0,
                                  child: Radio<String>(
                                    activeColor: AppColors.primary,
                                    value: 'Delite',
                                    groupValue: _foodType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _foodType = value!;
                                      });
                                    },
                                  ),
                                ),
                                const Text(
                                  'Delite',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Gap(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.0,
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
                                const Text(
                                  'Wet',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Gap(5),
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.0,
                                  child: Radio<String>(
                                    activeColor: AppColors.primary,
                                    value: 'Horeca',
                                    groupValue: _foodType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _foodType = value!;
                                      });
                                    },
                                  ),
                                ),
                                const Text(
                                  'Horeca',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: filterItems.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty
                                    ? "No Items Found !!"
                                    : "No Matching Items Found",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 81),
                              itemCount: filterItems.length,
                              itemBuilder: (context, index) {
                                return AdminItemCard(
                                  item: filterItems[index],
                                  index: index,
                                  isSelected: selectedIndex != null &&
                                      index == selectedIndex,
                                  parentItemName: filterItems[index]
                                          .parentItemId
                                          .isNotEmpty
                                      ? itemProv.allItems
                                          .firstWhere((e) =>
                                              e.itemId ==
                                              filterItems[index].parentItemId)
                                          .itemName
                                      : '',
                                  updateItem: updateItem,
                                  deleteItem: showDeleteItemDialog,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddItem(type: "Add", id: ''),
            ),
          );
        },
        child: Container(
          width: 160,
          height: 51,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            "Add Item",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
