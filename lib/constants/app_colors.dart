import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFe63946);
  static const Color accent = Color(0xFFF5A5AC);
}

class AppThemes {
  static final ThemeData normalTheme = ThemeData(
    primaryColor: AppColors.primary,
    hintColor: AppColors.accent,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
