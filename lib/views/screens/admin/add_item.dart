import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/item_model.dart';
import 'package:sss_retail/providers/item_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';

class AddItem extends StatefulWidget {
  final String type;
  final String id;
  const AddItem({super.key, required this.type, required this.id});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final List<TextEditingController> _itemDetails = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // XFile? _selectedImage;
  // final ImagePicker _picker = ImagePicker();

  String itemName = "";
  int itemOrder = -1;
  String itemType = "Dry";
  double itemPrice = 0.0;
  String? parentItem;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  void getDetails() async {
    final registerProv = Provider.of<UserProvider>(context, listen: false);
    await registerProv.getAllItems();
    if (widget.type == 'Update' && widget.id.isNotEmpty) {
      final item =
          registerProv.allItems.firstWhere((e) => e.itemId == widget.id);

      _itemDetails[0].text = item.itemName;
      itemName = item.itemName;
      _itemDetails[1].text = item.itemOrder.toString();
      itemOrder = item.itemOrder;
      _itemDetails[2].text = item.itemPrice.toString();
      itemPrice = item.itemPrice;
      itemType = item.itemType;
      if (item.parentItemId.isNotEmpty) {
        parentItem = item.parentItemId;
      }
    }
    await Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _itemDetails) {
      controller.dispose();
    }
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final XFile? pickedImage = await _picker.pickImage(
  //     source: await _showImageSourceDialog(),
  //     maxHeight: 600,
  //     maxWidth: 600,
  //   );

  //   if (pickedImage != null) {
  //     setState(() {
  //       _selectedImage = pickedImage;
  //     });
  //   }
  // }

  // Future<ImageSource> _showImageSourceDialog() async {
  //   return await showDialog<ImageSource>(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text(
  //             'Select Image From',
  //             style: TextStyle(
  //               color: Colors.black,
  //               fontSize: 24,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //           actionsAlignment: MainAxisAlignment.center,
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context, ImageSource.camera),
  //               child: const Text(
  //                 'Camera',
  //                 style: TextStyle(
  //                   color: Colors.black87,
  //                   fontSize: 19,
  //                 ),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.pop(context, ImageSource.gallery),
  //               child: const Text(
  //                 'Gallery',
  //                 style: TextStyle(
  //                   color: Colors.black87,
  //                   fontSize: 19,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       ImageSource.gallery;
  // }

  void updateUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final itemProv = Provider.of<ItemProvider>(context, listen: false);
      final userProv = Provider.of<UserProvider>(context, listen: false);
      if (itemOrder == -1 || parentItem != null) {
        itemOrder = userProv.allItems.length;
      }
      if (widget.id.isNotEmpty) {
        await itemProv.updateItem(
          ItemModel(
            itemId: widget.id,
            itemName: itemName,
            itemPrice: itemPrice,
            itemType: itemType,
            parentItemId: parentItem ?? '',
            itemOrder: itemOrder == userProv.allItems.length
                ? itemOrder
                : itemOrder - 1,
          ),
        );
      } else {
        await itemProv.addItem(
          ItemModel(
            itemId: '',
            itemName: itemName,
            itemPrice: itemPrice,
            itemType: itemType,
            parentItemId: parentItem ?? '',
            itemOrder: itemOrder == userProv.allItems.length
                ? itemOrder
                : itemOrder - 1,
          ),
        );
      }

      userProv.getAllItems();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final registerProv = Provider.of<UserProvider>(context, listen: false);

    final parentItems =
        registerProv.allItems.where((e) => e.parentItemId.isEmpty).toList();

    return Scaffold(
      appBar: CustomAppBar(title: "Add Item"),
      body: isLoading
          ? CustomLoader()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(21),
                  Container(
                    padding: const EdgeInsets.all(9),
                    margin:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 21),
                    width: double.infinity,
                    height: 490,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 11),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Name',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                              TextField(
                                controller: _itemDetails[0],
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    itemName = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Eg: Khari',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.accentColor2,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                    horizontal: 3,
                                  ),
                                  isDense: true,
                                ),
                                cursorColor: AppColors.accentColor2,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 11),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Order (optional)',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                              TextField(
                                controller: _itemDetails[1],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                enabled: widget.id.isEmpty,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    itemOrder = int.parse(value);
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Eg: 1',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.accentColor2,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                    horizontal: 3,
                                  ),
                                  isDense: true,
                                ),
                                cursorColor: AppColors.accentColor2,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 11),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Price in (₹)',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                              TextField(
                                controller: _itemDetails[2],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    itemPrice = double.parse(value);
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Eg: 120',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.accentColor2,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                    horizontal: 3,
                                  ),
                                ),
                                cursorColor: AppColors.accentColor2,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Type',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Gap(5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.0,
                                            child: Radio<String>(
                                              activeColor: AppColors.primary,
                                              value: 'Dry',
                                              groupValue: itemType,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  itemType = value!;
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
                                              value: 'Wet',
                                              groupValue: itemType,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  itemType = value!;
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
                                    ],
                                  ),
                                  Gap(5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.0,
                                            child: Radio<String>(
                                              activeColor: AppColors.primary,
                                              value: 'Horeca',
                                              groupValue: itemType,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  itemType = value!;
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
                                      Gap(5),
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.0,
                                            child: Radio<String>(
                                              activeColor: AppColors.primary,
                                              value: 'Delite',
                                              groupValue: itemType,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  itemType = value!;
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
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parent Item',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: parentItem,
                                    hint: Text(
                                      'Select Parent Item',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('None'),
                                      ),
                                      ...parentItems.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item.itemId,
                                          child: Text(
                                            item.itemName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? value) {
                                      setState(() {
                                        parentItem = value;
                                      });
                                    },
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.accentColor2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(27),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        updateUser();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 21,
                        ),
                        disabledBackgroundColor:
                            const Color.fromARGB(255, 200, 200, 200),
                      ),
                      child: Text(
                        widget.type == 'Add' ? 'Add Item' : 'Update Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
