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
      iconTheme: IconThemeData(color: Colors.black),
      toolbarHeight: 72,
      elevation: 2,
      backgroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
