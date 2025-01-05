import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/item_model.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/admin_item_card.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';

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
    Future.delayed(Duration(milliseconds: 1500), () {
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

  @override
  Widget build(BuildContext context) {
    final itemProv = Provider.of<UserProvider>(context);

    List<ItemModel> filterItems = _filterItems(itemProv.allItems);

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
                    Gap(15),
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
                              padding: EdgeInsets.only(bottom: 21),
                              itemCount: filterItems.length,
                              itemBuilder: (context, index) {
                                return AdminItemCard(
                                  item: filterItems[index],
                                  index: index,
                                  isSelected: selectedIndex != null &&
                                      index == selectedIndex,
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
