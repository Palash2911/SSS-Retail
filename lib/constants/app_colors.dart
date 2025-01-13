import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0XFF2ec4b6);
  static const Color accent = Color(0xFF5edbd0);
  static const Color accentColor2 = Color(0xFF93d9d3);
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
