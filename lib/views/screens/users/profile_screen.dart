import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/providers/auth_provider.dart';
import 'package:sss_retail/providers/user_provider.dart';
import 'package:sss_retail/views/components/custom_appbar.dart';
import 'package:sss_retail/views/components/custom_loader.dart';
import 'package:sss_retail/views/components/profile_card.dart';
import 'package:sss_retail/views/screens/users/edit_profile.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoading = true;
    });
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final authProv = Provider.of<Auth>(context, listen: false);

    authProv.getProfile();
    userProv.getUser(authProv.token);
    setState(() {
      isLoading = false;
    });
  }

  void _handleAction(String actionType) async {
    if (actionType == 'Logout') {
      await _showConfirmationDialog();
    } else if (actionType == 'Edit Profile') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const EditProfile()),
      );
    } else {
      await callNumber();
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Are You Sure?',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceAround,
            titlePadding: const EdgeInsets.symmetric(vertical: 40),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () async {
                  final authProv = Provider.of<Auth>(context, listen: false);
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                  await authProv.signOut();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully!')),
                    );
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> callNumber() async {
    await launchUrlString("tel://+919619142911").catchError((e) {
      throw Exception('Phone number not found in data');
    });
  }

  Widget _buildActionTile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color iconBgColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: iconBgColor.withOpacity(0.8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const Gap(15),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 24,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    final name = userProv.currUser.name;
    final isAdmin = userProv.currUser.isAdmin;
    final phoneNo = userProv.currUser.phone;
    final dealerShipName = userProv.currUser.dealerShipName;

    return Scaffold(
      appBar: CustomAppBar(title: "Profile"),
      body: isLoading
          ? CustomLoader()
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileCard(
                      uName: name,
                      uNum: phoneNo,
                      isAdmin: isAdmin,
                      uDealerName: dealerShipName,
                    ),
                    Gap(21),
                    _buildActionTile(
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      onTap: () => _handleAction('Edit Profile'),
                      iconBgColor: Colors.blue,
                    ),
                    _buildActionTile(
                      icon: Icons.contact_page,
                      label: 'Contact Us',
                      onTap: () => _handleAction('Contact Us'),
                      iconBgColor: Colors.green,
                    ),
                    _buildActionTile(
                      icon: Icons.logout_outlined,
                      label: 'Logout',
                      onTap: () => _handleAction('Logout'),
                      iconBgColor: Colors.deepOrange,
                    ),
                    Gap(21),
                  ],
                ),
              ),
            ),
    );
  }
}
