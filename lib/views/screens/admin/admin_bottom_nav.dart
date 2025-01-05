import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:sss_retail/constants/app_colors.dart';
import 'package:sss_retail/views/screens/admin/all_items.dart';
import 'package:sss_retail/views/screens/admin/current_orders.dart';
import 'package:sss_retail/views/screens/admin/past_orders.dart';
import 'package:sss_retail/views/screens/users/profile_screen.dart';

class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        resizeToAvoidBottomInset: true,
        padding: const EdgeInsets.all(9),
        screens: _buildScreens(),
        items: _navBarsItems(AppColors.primary),
        navBarStyle: NavBarStyle.style13,
        navBarHeight: 72,
        backgroundColor: Colors.white,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          colorBehindNavBar: Colors.white,
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 11,
              offset: Offset(0, -1),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildScreens() {
  return [
    const PastOrdersAdmin(),
    const CurrentOrderAdmin(),
    const AllItemScreen(),
    const ProfileScreen()
  ];
}

List<PersistentBottomNavBarItem> _navBarsItems(Color primaryColor) {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(
        Icons.history,
        size: 36,
      ),
      inactiveIcon: const Icon(
        Icons.schedule,
        size: 36,
      ),
      title: "History",
      activeColorPrimary: primaryColor,
      inactiveColorPrimary: Colors.grey,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(
        Icons.list_alt,
        size: 39,
      ),
      inactiveIcon: const Icon(
        Icons.list_alt_outlined,
        size: 39,
      ),
      title: "Orders",
      activeColorPrimary: primaryColor,
      inactiveColorPrimary: Colors.grey,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(
        Icons.inventory_2,
        size: 36,
      ),
      inactiveIcon: const Icon(
        Icons.inventory_2_outlined,
        size: 36,
      ),
      title: "Inventory",
      activeColorPrimary: primaryColor,
      inactiveColorPrimary: Colors.grey,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(
        Icons.person_4,
        size: 36,
      ),
      inactiveIcon: const Icon(
        Icons.person_4_outlined,
        size: 36,
      ),
      title: "Profile",
      activeColorPrimary: primaryColor,
      inactiveColorPrimary: Colors.grey,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ];
}
