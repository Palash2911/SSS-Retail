import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(209, 230, 57, 71);
  static const Color accent = Color(0xFFF5A5AC);
  static const Color accentColor2 = Color(0xFFFF637C);
}

class AppThemes {
  static final ThemeData normalTheme = ThemeData(
    primaryColor: AppColors.primary,
    hintColor: AppColors.accent,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 1,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
