import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/models/user_model.dart';
import 'package:sss_retail/providers/auth_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final List<TextEditingController> _profileDetails = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // XFile? _selectedImage;
  // final ImagePicker _picker = ImagePicker();

  String phoneNo = "";
  String name = "";
  String dealrshipName = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  void getDetails() {
    final profileProv = Provider.of<Auth>(context, listen: false);
    final registerProv = Provider.of<UserProvider>(context, listen: false);
    registerProv.getUser(
        profileProv.token, profileProv.isAdmin, profileProv.phoneNo);
    if (profileProv.token.isNotEmpty) {
      _profileDetails[0].text = registerProv.currUser.name;
      name = registerProv.currUser.name;
      _profileDetails[2].text = registerProv.currUser.dealerShipName;
      dealrshipName = registerProv.currUser.dealerShipName;
      _profileDetails[1].text = registerProv.currUser.phone;
      phoneNo = registerProv.currUser.phone;
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _profileDetails) {
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
    // if (_selectedImage == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please select an image !'),
    //     ),
    //   );
    //   return;
    // }
    setState(() {
      isLoading = true;
    });
    try {
      final registerProv = Provider.of<UserProvider>(context, listen: false);
      final auth = FirebaseAuth.instance;
      await registerProv.updateUser(
        UserModel(
          uid: auth.currentUser!.uid,
          name: name,
          phone: phoneNo,
          dealerShipName: dealrshipName,
          lastOrderId: "",
          isAdmin: false,
        ),
      );

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
    return Scaffold(
      appBar: CustomAppBar(title: "Update Profile"),
      body: isLoading
          ? CustomLoader()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gap(21),
                Container(
                  padding: const EdgeInsets.all(9),
                  margin:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 21),
                  width: double.infinity,
                  height: 390,
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
                              'Name',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            const Gap(3),
                            TextField(
                              controller: _profileDetails[0],
                              keyboardType: TextInputType.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
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
                              'Dealership / Store Name',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            const Gap(3),
                            TextField(
                              controller: _profileDetails[2],
                              keyboardType: TextInputType.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  dealrshipName = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Eg: Swami Samartha Distributors',
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
                              'Phone Number',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            const Gap(3),
                            TextField(
                              controller: _profileDetails[1],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              enabled: false,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Eg: 91 9212939102',
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
                                isDense: true,
                              ),
                              cursorColor: AppColors.accentColor2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(50),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: name.isNotEmpty &&
                            phoneNo.length == 13 &&
                            dealrshipName.isNotEmpty
                        ? () {
                            updateUser();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.accentColor2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                      disabledBackgroundColor:
                          const Color.fromARGB(255, 200, 200, 200),
                    ),
                    child: const Text(
                      'Update Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
