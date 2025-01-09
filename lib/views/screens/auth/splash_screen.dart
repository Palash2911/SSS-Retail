import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sss_retail/providers/auth_provider.dart';
import 'package:sss_retail/views/components/custom_loader.dart';

import '../../../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadScreen(context);
  }

  Future loadScreen(BuildContext ctx) async {
    var authProvider = Provider.of<Auth>(context, listen: false);
    var killProv = Provider.of<UserProvider>(context, listen: false);

    await Future.delayed(const Duration(seconds: 3), () async {
      await authProvider.autoLogin().then((_) async {
        if (authProvider.isAuth) {
          var userRole = await authProvider.checkUser();
          if (userRole != -1 && mounted) {
            if (userRole == 0) {
              Navigator.of(context).pushReplacementNamed('/user-bottom-nav');
            } else {
              await killProv.deleteOldOrders();
              Navigator.of(context).pushReplacementNamed('/admin-bottom-nav');
            }
          } else {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/register');
            }
          }
        } else {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomLoader(),
    );
  }
}
