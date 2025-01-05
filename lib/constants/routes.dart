import 'package:flutter/material.dart';
import 'package:sss_retail/views/screens/admin/admin_bottom_nav.dart';
import 'package:sss_retail/views/screens/auth/login.dart';
import 'package:sss_retail/views/screens/auth/otp.dart';
import 'package:sss_retail/views/screens/auth/register.dart';
import 'package:sss_retail/views/screens/auth/splash_screen.dart';
import 'package:sss_retail/views/screens/users/user_bottom_nav.dart';

var approutes = <String, WidgetBuilder>{
  // Inital Route
  '/': (context) => const SplashScreen(),

  '/login': (context) => const Login(),
  '/otp': (context) => const OTPScreen(),
  '/register': (context) => const RegisterScreen(),

  '/user-bottom-nav': (context) => const UserNav(),
  '/admin-bottom-nav': (context) => const AdminBottomNav(),
};
